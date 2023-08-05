import UIKit
import SceneKit
import ARKit



struct TextureFrame {
    var texture: UIImage
    var frame: ARFrame
    var mesh: ARMeshAnchor
}



class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    var anchorCount = 0
    
    var meshes: [TextureFrame] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        

            let btn = UIButton(frame: CGRect(x: 50, y: 150, width: 200, height: 50))
            btn.setTitle("SAVE", for: .normal)
        btn.backgroundColor = .gray
            btn.addTarget(self, action: #selector(pressed), for: .touchUpInside)

        view.addSubview(btn)
    }
    
    @objc func pressed() {
        print("PRESSED")
        saveScene()
//        sceneView.scene.rootNode.cleanup()
//        saveTexturedMesh()
    }
    
    func saveScene(){
        
        
        let documentsPath1 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = documentsPath1.appendingPathComponent("scan.scn")

        // Write the scene to the new url
        if !sceneView.scene.write(to: fileUrl, delegate: nil) {
            print("Failed to write scn scene to file!")

        } else {
            DispatchQueue.main.async {
                print("write scn scene to file!")
                let activityController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
                activityController.popoverPresentationController?.sourceView = self.view
                self.present(activityController, animated: true, completion: nil)
            }
            
        }
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .meshWithClassification
        configuration.environmentTexturing = .automatic
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let meshAnchor = anchor as? ARMeshAnchor else { return }
        let meshGeometry = ARSCNMeshGeometry(meshAnchor: meshAnchor)
        meshGeometry.node.name = anchor.name

        //        if let frame = sceneView.session.currentFrame{
        //            let material = SCNMaterial()
        //            material.diffuse.contents = frame.capturedImage
        //            node.addChildNode(meshGeometry.node(material: material))
        //        }
        
//        let node1 = SCNNode(geometry: meshGeometry.scnGeometry)
//
//        let material = SCNMaterial()
////                      material.diffuse.contents = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
//        material.diffuse.contents = UIImage(named: "texture")
//          material.diffuse.wrapT = SCNWrapMode.repeat
//          material.diffuse.wrapS = SCNWrapMode.repeat
//
//        material.isDoubleSided = true
//        node1.geometry?.firstMaterial = material
       makeTexturedMesh(mesh: meshAnchor, node: node)
        
        
//        let mat = SCNMaterial()
//        mat.diffuse.contents = UIImage(named: "texture")//sceneView.session.currentFrame?.capturedImage
//        mat.diffuse.wrapT = SCNWrapMode.repeat
//        mat.diffuse.wrapS = SCNWrapMode.repeat
//        mat.isDoubleSided = true
//        node.addChildNode(node)
        
//        node.addChildNode(meshGeometry.node(material:  UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)))
        anchorCount += 1
        print("ADD \(anchorCount)")
    }
    // scene update independent of drawing
    // data stays coherent for duration of render
    // Xcode instruments for resource monitoring
    /*
     Game performance template
     
     */
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
       return
        guard let meshAnchor = anchor as? ARMeshAnchor else { return }
        
        
        
        if let previousMeshNode = sceneView.scene.rootNode.childNode(withName: meshAnchor.name ?? "", recursively: true) {
            previousMeshNode.removeFromParentNode()
            print("removed \(meshAnchor.name ?? "")")
        }
        makeTexturedMesh(mesh: meshAnchor, node: node)
        //         for child in sceneView.scene.rootNode.childNodes {
        //             child.removeFromParentNode()
        //             child.cleanup()
        //         }
        
//        let meshGeometry = ARSCNMeshGeometry(meshAnchor: meshAnchor)
        
//                let mat = SCNMaterial()
//                mat.diffuse.contents = UIImage(named: "texture")//sceneView.session.currentFrame?.capturedImage
//                mat.isDoubleSided = false
//                node.addChildNode(meshGeometry.node(material: mat))
        
//        node.addChildNode(meshGeometry.node(material:  UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)))
        
        //        if let frame = sceneView.session.currentFrame{
        //           let capturedTexture = frame.capturedImage
        //            let material = SCNMaterial()
        //            material.diffuse.contents = capturedTexture
        //
        //            node.addChildNode(meshGeometry.node(material: material))
        //        }
        print("update")
    }
}

class ARSCNMeshGeometry {
    let scnGeometry: SCNGeometry
    var node: SCNNode {
        return SCNNode(geometry: scnGeometry)
    }
    init(meshAnchor: ARMeshAnchor) {
        let meshGeometry = meshAnchor.geometry
        // Vertices source
        let vertices = meshGeometry.vertices
        let verticesSource = SCNGeometrySource(buffer: vertices.buffer, vertexFormat: vertices.format, semantic: .vertex, vertexCount: vertices.count, dataOffset: vertices.offset, dataStride: vertices.stride)
        // Indices Element
        let faces = meshGeometry.faces
        let facesData = Data(bytesNoCopy: faces.buffer.contents(), count: faces.buffer.length, deallocator: .none)
        let facesElement = SCNGeometryElement(data: facesData, primitiveType: .triangles, primitiveCount: faces.count, bytesPerIndex: faces.bytesPerIndex)
        // Enabling this print statement causes the app to continue
        //        print(faces.count)
        
        scnGeometry = SCNGeometry(sources: [verticesSource], elements: [facesElement])
    }
    func node(material: Any) -> SCNNode {
        let scnMaterial = SCNMaterial()
        scnMaterial.diffuse.contents = material
        let geometry = scnGeometry
        geometry.materials = [scnMaterial]
        return SCNNode(geometry: geometry)
    }
}

extension SCNNode {
    func cleanup() {
        for child in childNodes {
            child.cleanup()
        }
        geometry = nil
    }
}

extension ViewController {
    func makeTexturedMesh(mesh: ARMeshAnchor, node: SCNNode){
        
//        let scene = SCNScene()
//        let node = scene.rootNode
//        let node = SCNNode()
        
//        let worldMeshes = renderer.worldMeshes
//        let textureCloud = renderer.textureCloud
        
//        print("texture images: \(textureImgs.count)")
        
        // each 'mesh' is a chunk of the whole scan
//        for mesh in worldMeshes {
       
            let aTrans = SCNMatrix4(mesh.transform)
            
        let vertices: ARGeometrySource = mesh.geometry.vertices
        let normals: ARGeometrySource = mesh.geometry.normals
        let faces: ARGeometryElement = mesh.geometry.faces
        var texture : UIImage
        
//        meshes.append(TextureFrame(texture: texture!, frame: sceneView.session.currentFrame!, mesh: mesh))
//            var texture = resizeImage(image: getTextureImage(frame: sceneView.session.currentFrame!)!, targetSize: CGSizeMake(200.0, 200.0))
        print("FACES COUNT = \(faces.count)")
            // a face is just a list of three indices, each representing a vertex
            for f in 0..<faces.count {
                print("f = \(f)")
                let face = face(at: f, faces: faces)
                // all verts of the face are in the box, so the triangle is visible
                var fVerts: [SCNVector3] = []
                var fNorms: [SCNVector3] = []
                var tCoords: [vector_float2] = []
                
                // convert each vertex and normal to world coordinates
                // get the texture coordinates
                for fv in face {
                    print("fv = \(fv)")
                    let vert = vertex(at: UInt32(fv), vertices: vertices)
                    let vTrans = SCNMatrix4MakeTranslation(vert[0], vert[1], vert[2])
                    let wTrans = SCNMatrix4Mult(vTrans, aTrans)
                    let wPos = SCNVector3(wTrans.m41, wTrans.m42, wTrans.m43)
                    fVerts.append(wPos)
                    
                    let norm = normal(at: UInt32(fv), normals: normals)
                    let nTrans = SCNMatrix4MakeTranslation(norm[0], norm[1], norm[2])
                    let wNTrans = SCNMatrix4Mult(nTrans, aTrans)
                    let wNPos = SCNVector3(wNTrans.m41, wTrans.m42, wNTrans.m43)
                    fNorms.append(wNPos)
                    
                    
                    // here's where you would find the frame that best fits
                    // for simplicity, just use the last frame here
                    let tFrame = sceneView.session.currentFrame
                    let tCoord = getTextureCoord(frame: tFrame!, vert: vert, aTrans: mesh.transform)
//                    let tCoords2 = vector_float2(Float(0.5), Float(0.5))
                    tCoords.append(tCoord)
                    texture = getTextureImage(frame: sceneView.session.currentFrame!)!
//                    texture = UIImage(named: "texture2")
//                    texture = getTextureImage(frame: tFrame!)
//                    texture = getCroppedTextureImage(frame: tFrame!, pos: tCoord)
                    
                    // visualize the normals if you want
//                    if mesh.inBox[fv] == 1 {
//                        //let normVis = lineBetweenNodes(positionA: wPos, positionB: wNPos, inScene: arView.scene)
//                        //arView.scene.rootNode.addChildNode(normVis)
//                    }
                }
//                allVerts.append(fVerts)
//                allNorms.append(fNorms)
//                allTCrds.append(tCoords)
                
                // make a single triangle mesh out each face
                let vertsSource = SCNGeometrySource(vertices: fVerts)
                let normsSource = SCNGeometrySource(normals: fNorms)
                let facesSource = SCNGeometryElement(indices: [UInt32(0), UInt32(1), UInt32(2)], primitiveType: .triangles)
                let textrSource = SCNGeometrySource(textureCoordinates: tCoords) // tCoords
                let geom = SCNGeometry(sources: [vertsSource, normsSource, textrSource], elements: [facesSource])
                
                // texture it with a saved camera frame
//                texture = UIImage(named: "texture2")
//                    texture = getTextureImage(frame: sceneView.session.currentFrame!)
//                texture = resizeImage(image: getTextureImage(frame: sceneView.session.currentFrame!)!, targetSize: CGSizeMake(200.0, 200.0))
//                    texture = getCroppedTextureImage(frame: tFrame!, pos: tCoord)
//                print("SIZE = \(texture.size)")
                let mat = SCNMaterial()
                mat.diffuse.contents = texture//UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)//texture
                mat.isDoubleSided = true
                mat.lightingModel = .constant
                geom.materials = [mat]
                let meshNode = SCNNode(geometry: geom)
               
                
                //node.addChildNode(meshNode)
//                print("ADD NODE")
                DispatchQueue.main.async {
                    self.sceneView.scene.rootNode.addChildNode(meshNode)
                }

                
            }
       
        }
//        scanTapped()
//        print("SAVE NODE")
//        // Get the document directory name the write a url for the object replacing its extention with scn
//        let documentsPath1 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileUrl = documentsPath1.appendingPathComponent("scan.scn")
//
//        // Write the scene to the new url
//        if !scene.write(to: fileUrl, delegate: nil) {
//            print("Failed to write scn scene to file!")
//
//        } else {
//            print("write scn scene to file!")
//            let activityController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
//            activityController.popoverPresentationController?.sourceView = self.view
//            self.present(activityController, animated: true, completion: nil)
//        }

//    }
    
   
    
    func saveTexturedMesh(){
        
                let scene = SCNScene()
                let node = scene.rootNode
    
        for textFrame in meshes {
            let mesh = textFrame.mesh
            
            let aTrans = SCNMatrix4(mesh.transform)
            
            let vertices: ARGeometrySource = mesh.geometry.vertices
            let normals: ARGeometrySource = mesh.geometry.normals
            let faces: ARGeometryElement = mesh.geometry.faces
            var texture = textFrame.texture
            
            for f in 0..<faces.count {
                
                let face = face(at: f, faces: faces)
                // all verts of the face are in the box, so the triangle is visible
                var fVerts: [SCNVector3] = []
                var fNorms: [SCNVector3] = []
                var tCoords: [vector_float2] = []
                
                for fv in face {
                    print("fv = \(fv)")
                    let vert = vertex(at: UInt32(fv), vertices: vertices)
                    let vTrans = SCNMatrix4MakeTranslation(vert[0], vert[1], vert[2])
                    let wTrans = SCNMatrix4Mult(vTrans, aTrans)
                    let wPos = SCNVector3(wTrans.m41, wTrans.m42, wTrans.m43)
                    fVerts.append(wPos)
                    
                    let norm = normal(at: UInt32(fv), normals: normals)
                    let nTrans = SCNMatrix4MakeTranslation(norm[0], norm[1], norm[2])
                    let wNTrans = SCNMatrix4Mult(nTrans, aTrans)
                    let wNPos = SCNVector3(wNTrans.m41, wTrans.m42, wNTrans.m43)
                    fNorms.append(wNPos)
                    
                    let tFrame = textFrame.frame
                    let tCoord = getTextureCoord(frame: tFrame, vert: vert, aTrans: mesh.transform)
                    //                    let tCoords2 = vector_float2(Float(0.5), Float(0.5))
                    tCoords.append(tCoord)
                    
                }
                
                let vertsSource = SCNGeometrySource(vertices: fVerts)
                let normsSource = SCNGeometrySource(normals: fNorms)
                let facesSource = SCNGeometryElement(indices: [UInt32(0), UInt32(1), UInt32(2)], primitiveType: .triangles)
                let textrSource = SCNGeometrySource(textureCoordinates: tCoords) // tCoords
                let geom = SCNGeometry(sources: [vertsSource, normsSource, textrSource], elements: [facesSource])
                
                let mat = SCNMaterial()
                mat.diffuse.contents = texture
                mat.isDoubleSided = true
                mat.lightingModel = .constant
                geom.materials = [mat]
                let meshNode = SCNNode(geometry: geom)
                
                
                node.addChildNode(meshNode)
                
                
            }
            
        }
        
                let documentsPath1 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileUrl = documentsPath1.appendingPathComponent("scan.scn")
        
                // Write the scene to the new url
                if !scene.write(to: fileUrl, delegate: nil) {
                    print("Failed to write scn scene to file!")
        
                } else {
                    print("write scn scene to file!")
                    let activityController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
                    activityController.popoverPresentationController?.sourceView = self.view
                    self.present(activityController, animated: true, completion: nil)
                }
    }
//        scanTapped()
//        print("SAVE NODE")
//        // Get the document directory name the write a url for the object replacing its extention with scn
//        let documentsPath1 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileUrl = documentsPath1.appendingPathComponent("scan.scn")
//
//        // Write the scene to the new url
//        if !scene.write(to: fileUrl, delegate: nil) {
//            print("Failed to write scn scene to file!")
//
//        } else {
//            print("write scn scene to file!")
//            let activityController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
//            activityController.popoverPresentationController?.sourceView = self.view
//            self.present(activityController, animated: true, completion: nil)
//        }

//    }

}
