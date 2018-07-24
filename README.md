# JJScanningView<br>
用法:<br>
添加扫描二维码界面<br>
`
JJScanningView *scan = [[JJScanningView alloc] initWithFrame:self.view.bounds superVC:self];
`<br>
`scan.delegate = self;
`<br>
`
[self.view addSubview:scan];
`<br>
`
[scan startScan];
`<br>
实现代理方法:<br>
```
- (void)JJScanningViewDidOutputMetadataObjects:(NSArray *)metadataObjects{代码}
```


