import UIKit
import SceneKit
import ARKit

class SecondViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    //    var sceneView: ARSCNView = ARSCNView()
    
    var configuration: ARWorldTrackingConfiguration!
    var meshNode: SCNNode?
    var meshTextures: [SCNNode: UIImage] = [:] // Словарь для хранения текстур для каждого меша
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        sceneView.frame = view.bounds
        //        view.addSubview(sceneView)
        // Настройка ARSCNView
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        // Настройка конфигурации ARKit с использованием LiDAR
        configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .meshWithClassification // Включаем реконструкцию меша с помощью классификации
        configuration.environmentTexturing = .automatic // Автоматическая текстурирование
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            sceneView.session.run(configuration)
        } else {
            print("Данное устройство не поддерживает реконструкцию меша.")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        guard let meshAnchor = anchor as? ARMeshAnchor else { return }
        let meshGeometry = ARSCNMeshGeometry(meshAnchor: meshAnchor)//meshAnchor.geometry
        let meshNode = SCNNode(geometry: meshGeometry.node.geometry)

        node.addChildNode(meshNode)
        
        // Создаем текстуру для меша
        if let frame = sceneView.session.currentFrame {
            let capturedTexture = frame.capturedImage
            let textureImage = UIImage(ciImage: CIImage(cvPixelBuffer: capturedTexture))
            
            // Сохраняем текстуру для каждого меша
            meshTextures[meshNode] = textureImage
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // Применяем текстуры к мешам после их создания
        for (meshNode, textureImage) in meshTextures {
            if let meshGeometry = meshNode.geometry as? ARSCNFaceGeometry {
                let material = SCNMaterial()
                material.diffuse.contents = textureImage
//                material.diffuse.contents = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
                // Применяем текстуру к материалу меша
                meshGeometry.firstMaterial = material
            }
        }
        
        // Очищаем словарь текстур после их применения
        meshTextures.removeAll()
    }
}
