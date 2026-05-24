import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let exportChannel = FlutterMethodChannel(name: "com.fina.export",
                                              binaryMessenger: controller.binaryMessenger)
    exportChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "shareCsv" {
        if let args = call.arguments as? [String: Any],
           let csvContent = args["csvContent"] as? String,
           let filename = args["filename"] as? String {
          self.shareCsv(content: csvContent, filename: filename, controller: controller)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func shareCsv(content: String, filename: String, controller: UIViewController) {
    let tempDir = FileManager.default.temporaryDirectory
    let fileURL = tempDir.appendingPathComponent(filename)
    
    do {
      try content.write(to: fileURL, atomically: true, encoding: .utf8)
      let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
      
      // For iPad
      if let popover = activityViewController.popoverPresentationController {
        popover.sourceView = controller.view
        popover.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
      }
      
      controller.present(activityViewController, animated: true, completion: nil)
    } catch {
      print("Error writing CSV file: \(error)")
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
