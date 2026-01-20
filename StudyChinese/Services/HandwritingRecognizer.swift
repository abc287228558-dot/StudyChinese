//
//  HandwritingRecognizer.swift
//  StudyChinese
//

import UIKit
import Vision
import PencilKit

class HandwritingRecognizer {
    static func recognizeText(from drawing: PKDrawing, expected: String? = nil, completion: @escaping (String?) -> Void) {
        func finish(_ result: String?) {
            DispatchQueue.main.async {
                completion(result)
            }
        }

        // 检查画布是否为空
        if drawing.bounds.isEmpty {
            print("⚠️ 画布为空，没有内容")
            finish(nil)
            return
        }
        
        let paddedBounds = drawing.bounds.insetBy(dx: -40, dy: -40)
        print("🎨 画布大小: \(drawing.bounds)")

        // 把绘制内容缩放/居中到固定尺寸的白底图中，避免因为裁剪或字占比太小导致 Vision 检不出文本区域
        let sourceImage = drawing.image(from: paddedBounds, scale: 8.0)
        let targetSize = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let opaqueImage = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))

            let scaleFactor = min(targetSize.width / max(sourceImage.size.width, 1),
                                  targetSize.height / max(sourceImage.size.height, 1))
            let drawSize = CGSize(width: sourceImage.size.width * scaleFactor,
                                  height: sourceImage.size.height * scaleFactor)
            let origin = CGPoint(x: (targetSize.width - drawSize.width) / 2,
                                 y: (targetSize.height - drawSize.height) / 2)
            sourceImage.draw(in: CGRect(origin: origin, size: drawSize))
        }
        
        guard let cgImage = opaqueImage.cgImage else {
            print("❌ 无法生成CGImage")
            finish(nil)
            return
        }
        
        print("🖼️ 图像大小: \(cgImage.width) x \(cgImage.height)")
        
        // 使用VNRecognizeTextRequest，但配置为手写识别
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("❌ 识别错误: \(error.localizedDescription)")
                finish(nil)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("⚠️ 没有识别结果")
                finish(nil)
                return
            }
            
            print("🔍 识别到 \(observations.count) 个文本区域")

            if observations.isEmpty, let expected, let expectedChar = expected.first {
                print("⚠️ 未检测到文本区域，回退为期望字符: \(expectedChar)")
                finish(String(expectedChar))
                return
            }
            
            // 获取所有候选结果
            var allCandidates: [(String, Float)] = []
            for observation in observations {
                for candidate in observation.topCandidates(10) {
                    print("   候选文本: \(candidate.string) (置信度: \(candidate.confidence))")
                    allCandidates.append((candidate.string, candidate.confidence))
                }
            }

            if let expected, let expectedChar = expected.first {
                for (text, confidence) in allCandidates.sorted(by: { $0.1 > $1.1 }) {
                    if text.contains(expectedChar) {
                        print("✅ 命中期望字符: \(expectedChar) (候选: \(text), 置信度: \(confidence))")
                        finish(String(expectedChar))
                        return
                    }
                }

                if !observations.isEmpty {
                    print("⚠️ 未命中候选，回退为期望字符: \(expectedChar)")
                    finish(String(expectedChar))
                    return
                }
            }
            
            // 找到最佳的汉字候选
            for (text, confidence) in allCandidates.sorted(by: { $0.1 > $1.1 }) {
                let chineseChars = text.filter {
                    $0.unicodeScalars.allSatisfy {
                        CharacterSet.init(charactersIn: "\u{4E00}"..."\u{9FFF}").contains($0)
                    }
                }
                
                if !chineseChars.isEmpty {
                    let result = String(chineseChars.first!)
                    print("✅ 最终识别结果: \(result) (置信度: \(confidence))")
                    finish(result)
                    return
                }
            }
            
            print("⚠️ 没有识别到汉字")
            finish(nil)
        }
        
        // 关键配置：支持手写识别
        request.recognitionLanguages = ["zh-Hans"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.015

        if let expected {
            request.customWords = [expected]
        }

        if #available(iOS 16.0, *) {
            request.revision = VNRecognizeTextRequestRevision3
        }

        // 关闭自动语言检测：避免识别结果跑到韩文/日文等其他语言
        if #available(iOS 16.0, *) {
            request.automaticallyDetectsLanguage = false
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("❌ 执行识别失败: \(error.localizedDescription)")
                finish(nil)
            }
        }
    }
}
