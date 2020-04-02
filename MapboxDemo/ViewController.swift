//
//  ViewController.swift
//  MapboxDemo
//
//  Created by Aditya Pandey on 02/04/20.
//  Copyright © 2020 Tourio. All rights reserved.
//

import UIKit
import Mapbox

class ViewController: UIViewController, MGLMapViewDelegate {
    var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/mapbox/streets-v11")
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 28.525753, longitude: 77.185286), zoomLevel: 18, animated: false)
        view.addSubview(mapView)
        
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        loadGeoJson()
    }
    
    func loadGeoJson() {
        DispatchQueue.global().async {
            // Get the path for example.geojson in the app’s bundle.
            guard let jsonUrl = Bundle.main.url(forResource: "demo-with-polygon", withExtension: "geojson") else {
                preconditionFailure("Failed to load local GeoJSON file")
            }
            
            guard let jsonData = try? Data(contentsOf: jsonUrl) else {
                preconditionFailure("Failed to parse GeoJSON file")
            }
            
            DispatchQueue.main.async {
                self.setSource(geoJson: jsonData)
            }
        }
    }
    
    func setSource(geoJson: Data) {
        // Add our GeoJSON data to the map as an MGLGeoJSONSource.
        // We can then reference this data from an MGLStyleLayer.
        
        // MGLMapView.style is optional, so you must guard against it not being set.
        guard let style = self.mapView.style else { return }
        
        guard let featureCollectionFromGeoJSON = try? MGLShape(data: geoJson, encoding: String.Encoding.utf8.rawValue) as? MGLShapeCollectionFeature else {
            fatalError("Could not generate MGLShapeCollectionFeature")
        }
        
        let source = MGLShapeSource(identifier: "test-source", shape: featureCollectionFromGeoJSON, options: nil)
        style.addSource(source)
        
        style.importImages()
        style.showPoints(from: source)
        style.showPolygons(from: source)
    }
}

extension MGLStyle {
    func importImages() {
        setImage(UIImage(named: "poi_unvisited")!, forName: "poi-unvisited")
    }
    
    func showPoints(from source: MGLShapeSource) {
        let symbolLayer = MGLSymbolStyleLayer(identifier: "test-point", source: source)
        symbolLayer.iconImageName = NSExpression(forConstantValue: "poi-unvisited")
        symbolLayer.text = NSExpression(forKeyPath: "title")
        addLayer(symbolLayer)
    }
    
    func showPolygons(from source: MGLShapeSource) {
        let polygonLayer = MGLFillStyleLayer(identifier: "test-polygon", source: source)
        polygonLayer.fillColor = NSExpression(forConstantValue: UIColor(red: 0, green: 0, blue: 1, alpha: 1))
        polygonLayer.fillOpacity = NSExpression(forConstantValue: 0.2)
        
        addLayer(polygonLayer)
    }
}

