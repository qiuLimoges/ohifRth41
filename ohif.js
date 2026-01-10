window.config = {
  // default: '/'
  routerBasename: '/',
  extensions: [],
  
  // Enable modes - including longitudinal mode for PET-CT fusion
  modes: [],
  defaultMode: '',
  
  showStudyList: true,
  filterQueryParam: false,
  
  // Enable study browser for multi-study viewing (important for PET-CT)
  studyBrowser: {
    showPatientInfo: true,
    showSeriesDescription: true,
    showModality: true,
    showStudyDate: true,
  },
  
  // Enable timepoints and tracking for longitudinal studies (PET-CT fusion)
  enableTimepoints: true,
  enableStudyComparison: true,
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
      },
    ],
  },
  whiteLabeling: {
    /* Used to replace the default Logo */
  },
  // Extensions should be able to suggest default values for these?
  // Or we can require that these be explicitly set
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
    // Supported Keys: https://craig.is/killing/mice
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
    // clearAnnotations
    { commandName: 'nextImage', label: 'Next Image', keys: ['down'] },
    { commandName: 'previousImage', label: 'Previous Image', keys: ['up'] },
    // firstImage
    // lastImage
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
  
  // Cornerstone Extension Configuration
  cornerstoneExtensionConfig: {
    // Enable image rendering tools
    tools: [
      'ArrowAnnotate',
      'Bidirectional',
      'Length',
      'Angle',
      'CircleRoi',
      'EllipseRoi',
      'FreehandRoi',
      'Probe',
      'RectangleRoi',
      'TextMarker',
      'Eraser',
      'Pan',
      'Zoom',
      'Wwwc',
      'StackScroll',
      'Magnify',
      'Rotate',
      'Flip',
    ],
    // Default tool for active viewport
    defaultTool: 'Zoom',
  },

  // Default viewport settings
  defaultViewport: {
    background: [0, 0, 0], // Black background
    orientation: 'axial',
    viewportType: 'stack',
    toolGroupId: 'default',
    viewportId: '',
    customViewportProps: {},
  },

  // Supported modalities - Enable PET, CT, MRI, NM, etc.
  supportedModalities: ['CT', 'MR', 'PT', 'PET', 'NM', 'US', 'CR', 'DX', 'MG', 'XA', 'RF'],
  
  // Enable study list functions
  studyListFunctionsEnabled: true,
  
  // Enable timepoints browser for longitudinal studies (required for PET-CT fusion)
  enableTimepoints: true,
  
  // Enable hanging protocols
  enableHangingProtocols: true,
  
  // Enable image fusion and registration (PET-CT alignment)
  enableImageFusion: true,
  enableImageRegistration: true,
  
  // Enable synchronization between multiple series (important for PET-CT viewing)
  enableSeriesSynchronization: true,
  
  // Enable viewport linking for PET-CT fusion viewing
  enableViewportLinking: true,
  
  // Window/Level presets for different modalities
  windowPresets: {
    // CT presets
    CT: {
      SoftTissue: { window: 400, level: 50 },
      Bone: { window: 1800, level: 400 },
      Lung: { window: 1500, level: -600 },
      Brain: { window: 80, level: 40 },
      Abdomen: { window: 400, level: 50 },
      Liver: { window: 150, level: 90 },
      Mediastinum: { window: 350, level: 50 },
      Angio: { window: 600, level: 300 },
    },
    // PET presets
    PET: {
      Standard: { window: 5, level: 2.5 },
      Lung: { window: 6, level: 3 },
      Liver: { window: 7, level: 3.5 },
      Brain: { window: 8, level: 4 },
      SUV: { window: 10, level: 5 },
    },
    // MRI presets
    MR: {
      Brain: { window: 2000, level: 500 },
      Spine: { window: 800, level: 400 },
      T1: { window: 400, level: 200 },
      T2: { window: 1000, level: 500 },
      FLAIR: { window: 1200, level: 600 },
    },
  },
  
  // Study browser configuration
  studyBrowser: {
    showPatientInfo: true,
    showSeriesDescription: true,
    showModality: true,
    showStudyDate: true,
  },
  
  // Viewer preferences
  viewerPreferences: {
    // Enable sync between viewports
    enableSync: true,
    // Enable crosshair
    enableCrosshair: true,
    // Enable measurement tools
    enableMeasurementTools: true,
    // Enable annotation tools
    enableAnnotationTools: true,
  },
  
};

