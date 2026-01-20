# StudyChinese - 小学生语文学习iPad应用

## 功能概述

### 1. 录入功能
- 使用iPad相机拍摄语文书词汇表
- 自动识别照片中的汉字
- 可以编辑和删除识别结果
- 保存词汇集并自定义名称

### 2. 练习功能
- 选择已保存的词汇集进行练习
- 显示词汇的拼音（带声调，如：人 → rén）
- 在田字格中使用Apple Pencil书写汉字
- 自动识别手写内容并判断对错
- 错误的词汇会被筛选出来继续练习
- 支持多次"复活"直到全部正确

### 3. 复习记录
- 记录所有练习历史
- 显示词汇集名称、完成时间
- 统计复活次数（重新练习错误词汇的次数）

## 技术实现

### 拼音转换
使用iOS原生的`CFStringTransform`实现汉字到拼音的转换：
```swift
let mutableString = NSMutableString(string: "人") as CFMutableString
CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
// 结果: "rén"
```

### 文字识别
- 使用Vision框架的`VNRecognizeTextRequest`识别照片中的汉字
- 支持简体中文和繁体中文

### 手写识别
- 使用PencilKit的`PKCanvasView`提供书写界面
- 将手写内容转换为图像后使用Vision框架识别

### 数据存储
- 使用UserDefaults存储词汇集和练习记录
- 支持JSON编码/解码

## 项目结构

```
StudyChinese/
├── Models/
│   └── WordSet.swift              # 数据模型
├── Views/
│   ├── MainTabView.swift          # 主界面（三个Tab）
│   ├── WordSetListView.swift      # 词汇集列表
│   ├── WordSetDetailView.swift    # 词汇集详情
│   ├── WordEditView.swift         # 编辑词汇
│   ├── ImagePickerView.swift      # 照片选择和识别
│   ├── PracticeListView.swift     # 练习列表
│   ├── PracticeView.swift         # 练习界面
│   ├── TianZiGeView.swift         # 田字格组件
│   └── RecordsView.swift          # 练习记录
├── Services/
│   ├── DataManager.swift          # 数据管理
│   └── HandwritingRecognizer.swift # 手写识别
└── Utilities/
    └── PinyinConverter.swift      # 拼音转换工具
```

## 使用说明

1. **录入词汇**
   - 点击"录入"标签
   - 点击相机图标选择照片
   - 等待自动识别
   - 删除不需要的词汇
   - 输入词汇集名称并保存

2. **开始练习**
   - 点击"练习"标签
   - 选择要练习的词汇集
   - 根据拼音在田字格中书写汉字
   - 点击"完成"检查答案
   - 错误的词汇会重新练习

3. **查看记录**
   - 点击"记录"标签
   - 查看所有练习历史和复活次数

## 注意事项

- 需要iPad设备和Apple Pencil以获得最佳体验
- 首次使用需要授权相册访问权限
- 手写识别准确度取决于书写规范程度
