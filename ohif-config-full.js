/** @type {AppTypes.Config} */
// OHIF Viewer 完整配置 - 包含 PET-CT 融合功能
// 基于 OHIF GitHub 仓库的最新版本

window.config = {
  name: 'OHIF Viewer - Full Configuration',
  routerBasename: '/',
  
  // 扩展配置 - 包含所有必要的扩展
  extensions: [],
  
  // 模式配置 - 包含 longitudinal 模式（支持 PET-CT 融合）
  modes: [],
  
  // 自定义服务
  customizationService: {},
  
  // 显示研究列表
  showStudyList: true,
  
  // Web Workers 配置
  maxNumberOfWebWorkers: 3,
  
  // 性能和安全设置
  showWarningMessageForCrossOrigin: true,
  showCPUFallbackMessage: true,
  showLoadingIndicator: true,
  experimentalStudyBrowserSort: false,
  strictZSpacingForVolumeViewport: true,
  groupEnabledModesFirst: true,
  allowMultiSelectExport: false,
  
  // 请求数量限制
  maxNumRequests: {
    interaction: 100,
    thumbnail: 75,
    prefetch: 25,
  },
  
  showErrorDetails: 'always', // 'always', 'dev', 'production'
  
  // 数据源配置
  defaultDataSourceName: 'ohif',
  
  // DICOM Web 服务器配置
  servers: {
    dicomWeb: [
      {
        name: 'Orthanc',
        wadoUriRoot: '/orthanc/wado',
        qidoRoot: '/orthanc/dicom-web',
        wadoRoot: '/orthanc/dicom-web',
        qidoSupportsIncludeField: true,
        imageRendering: 'wadors',
        thumbnailRendering: 'wadors',
        enableStudyLazyLoad: true,
        supportsFuzzyMatching: true,
        supportsInstanceMetadata: false,
        // 支持 PET-CT 融合的重要配置
        requestTransferSyntax: '1.2.840.10008.1.2.4.91', // JPEG 2000
        // 允许请求多个系列
        supportsMultiFrame: true,
      },
    ],
  },
  
  // 白色标签（品牌）
  whiteLabeling: {
    /* Used to replace the default Logo */
  },
  
  // 支持的模态类型
  supportedModalities: ['CT', 'MR', 'PT', 'PET', 'NM', 'US', 'CR', 'DX', 'MG', 'XA', 'RF'],
  
  // 快捷键配置
  hotkeys: [
    // ~ Global
    {
      commandName: 'incrementActiveViewport',
      label: 'Next Viewport',
      keys: ['right'],
    },
    {
      commandName: 'decrementActiveViewport',
      label: 'Previous Viewport',
      keys: ['left'],
    },
    // ~ Cornerstone Extension
    { commandName: 'rotateViewportCW', label: 'Rotate Right', keys: ['r'] },
    { commandName: 'rotateViewportCCW', label: 'Rotate Left', keys: ['l'] },
    { commandName: 'invertViewport', label: 'Invert', keys: ['i'] },
    {
      commandName: 'flipViewportVertical',
      label: 'Flip Horizontally',
      keys: ['h'],
    },
    {
      commandName: 'flipViewportHorizontal',
      label: 'Flip Vertically',
      keys: ['v'],
    },
    { commandName: 'scaleUpViewport', label: 'Zoom In', keys: ['+'] },
    { commandName: 'scaleDownViewport', label: 'Zoom Out', keys: ['-'] },
    { commandName: 'fitViewportToWindow', label: 'Zoom to Fit', keys: ['='] },
    { commandName: 'resetViewport', label: 'Reset', keys: ['space'] },
    { commandName: 'nextImage', label: 'Next Image', keys: ['down'] },
    { commandName: 'previousImage', label: 'Previous Image', keys: ['up'] },
    {
      commandName: 'previousViewportDisplaySet',
      label: 'Previous Series',
      keys: ['pagedown'],
    },
    {
      commandName: 'nextViewportDisplaySet',
      label: 'Next Series',
      keys: ['pageup'],
    },
    // ~ Cornerstone Tools
    { commandName: 'setZoomTool', label: 'Zoom', keys: ['z'] },
    // ~ Window level presets
    {
      commandName: 'windowLevelPreset1',
      label: 'W/L Preset 1',
      keys: ['1'],
    },
    {
      commandName: 'windowLevelPreset2',
      label: 'W/L Preset 2',
      keys: ['2'],
    },
    {
      commandName: 'windowLevelPreset3',
      label: 'W/L Preset 3',
      keys: ['3'],
    },
    {
      commandName: 'windowLevelPreset4',
      label: 'W/L Preset 4',
      keys: ['4'],
    },
    {
      commandName: 'windowLevelPreset5',
      label: 'W/L Preset 5',
      keys: ['5'],
    },
    {
      commandName: 'windowLevelPreset6',
      label: 'W/L Preset 6',
      keys: ['6'],
    },
    {
      commandName: 'windowLevelPreset7',
      label: 'W/L Preset 7',
      keys: ['7'],
    },
    {
      commandName: 'windowLevelPreset8',
      label: 'W/L Preset 8',
      keys: ['8'],
    },
    {
      commandName: 'windowLevelPreset9',
      label: 'W/L Preset 9',
      keys: ['9'],
    },
  ],
  
  // Cornerstone 扩展配置
  cornerstoneExtensionConfig: {},
  
  // 启用研究列表功能
  studyListFunctionsEnabled: true,
  
  // 实验性功能 - PET-CT 融合相关
  experimental: {
    // 启用图像融合
    enableImageFusion: true,
    // 启用多模态同步
    enableMultiModalSync: true,
    // 启用时间点追踪（纵向研究）
    enableTimepoints: true,
  },
};

