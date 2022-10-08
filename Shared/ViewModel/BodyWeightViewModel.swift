//
//  BodyWeightViewModel.swift
//  PRTracker
//
//  Created by Brevin Blalock on 6/13/22.
//

import Foundation

class BodyWeightViewModel: ObservableObject {
    
    @Published var weights = [BodyWeightModel]()
    let jsonData = """
         {"date":"7/15/2022","Weight":215},
         {"date":"4/13/2022","Weight":231},
         {"date":"2/22/2022","Weight":260},
         {"date":"2/6/2021","Weight":238},
         {"date":"4/28/2022","Weight":281},
         {"date":"2/11/2021","Weight":272},
         {"date":"5/16/2022","Weight":239},
         {"date":"3/20/2022","Weight":253},
         {"date":"5/31/2021","Weight":265},
         {"date":"11/5/2021","Weight":288},
         {"date":"5/31/2022","Weight":270},
         {"date":"5/12/2022","Weight":231},
         {"date":"6/16/2021","Weight":225},
         {"date":"1/16/2022","Weight":257},
         {"date":"11/21/2021","Weight":222},
         {"date":"1/23/2021","Weight":226},
         {"date":"5/26/2021","Weight":205},
         {"date":"5/8/2021","Weight":248},
         {"date":"1/7/2022","Weight":204},
         {"date":"2/8/2021","Weight":261},
         {"date":"9/26/2021","Weight":223},
         {"date":"4/19/2021","Weight":259},
         {"date":"3/7/2021","Weight":251},
         {"date":"1/22/2021","Weight":245},
         {"date":"3/3/2021","Weight":249},
         {"date":"7/6/2022","Weight":268},
         {"date":"3/21/2021","Weight":289},
         {"date":"7/4/2022","Weight":246},
         {"date":"2/12/2021","Weight":206},
         {"date":"7/2/2022","Weight":220},
         {"date":"12/25/2021","Weight":202},
         {"date":"5/18/2021","Weight":270},
         {"date":"8/11/2021","Weight":295},
         {"date":"6/8/2021","Weight":284},
         {"date":"3/11/2022","Weight":269},
         {"date":"12/2/2021","Weight":291},
         {"date":"7/9/2021","Weight":278},
         {"date":"1/6/2022","Weight":215},
         {"date":"5/27/2021","Weight":206},
         {"date":"8/2/2021","Weight":228},
         {"date":"5/12/2021","Weight":213},
         {"date":"5/18/2021","Weight":279},
         {"date":"4/23/2022","Weight":275},
         {"date":"1/18/2021","Weight":216},
         {"date":"4/1/2022","Weight":241},
         {"date":"9/17/2021","Weight":202},
         {"date":"8/25/2021","Weight":247},
         {"date":"3/25/2022","Weight":293},
         {"date":"12/24/2021","Weight":201},
         {"date":"7/3/2021","Weight":223},
         {"date":"2/18/2022","Weight":239},
         {"date":"4/24/2022","Weight":240},
         {"date":"4/19/2022","Weight":266},
         {"date":"9/26/2021","Weight":242},
         {"date":"6/12/2022","Weight":226},
         {"date":"4/1/2021","Weight":256},
         {"date":"2/19/2021","Weight":226},
         {"date":"10/12/2021","Weight":254},
         {"date":"5/15/2021","Weight":275},
         {"date":"1/14/2021","Weight":247},
         {"date":"2/21/2022","Weight":287},
         {"date":"7/21/2021","Weight":253},
         {"date":"7/6/2022","Weight":263},
         {"date":"2/24/2021","Weight":284},
         {"date":"1/8/2022","Weight":211},
         {"date":"3/22/2021","Weight":245},
         {"date":"8/22/2021","Weight":257},
         {"date":"4/22/2022","Weight":240},
         {"date":"4/5/2021","Weight":233},
         {"date":"3/20/2022","Weight":202},
         {"date":"4/18/2022","Weight":278},
         {"date":"4/26/2021","Weight":219},
         {"date":"11/12/2021","Weight":262},
         {"date":"10/22/2021","Weight":289},
         {"date":"8/22/2021","Weight":296},
         {"date":"5/4/2021","Weight":276},
         {"date":"7/2/2021","Weight":286},
         {"date":"1/8/2021","Weight":298},
         {"date":"11/17/2021","Weight":233},
         {"date":"8/24/2021","Weight":275},
         {"date":"6/23/2021","Weight":267},
         {"date":"5/10/2022","Weight":248},
         {"date":"5/8/2021","Weight":273},
         {"date":"5/1/2021","Weight":244},
         {"date":"4/8/2021","Weight":218},
         {"date":"6/30/2021","Weight":225},
         {"date":"1/7/2022","Weight":254},
         {"date":"6/6/2022","Weight":255},
         {"date":"2/5/2022","Weight":205},
         {"date":"7/20/2022","Weight":222},
         {"date":"8/15/2021","Weight":202},
         {"date":"2/8/2021","Weight":236},
         {"date":"4/27/2022","Weight":288},
         {"date":"4/30/2021","Weight":269},
         {"date":"6/7/2021","Weight":244},
         {"date":"6/4/2021","Weight":203},
         {"date":"8/5/2021","Weight":216},
         {"date":"6/6/2021","Weight":223},
         {"date":"4/25/2022","Weight":212},
         {"date":"1/5/2022","Weight":256}
     """.data(using: .utf8)!
    
    
    init() {
        getWeight()
    }
    
    func getWeight() {
        guard let sourceURL = Bundle.main.url(forResource: "bodyWeightData", withExtension: "json") else {
            fatalError("could not find data")
        }
        
        guard let dataJSONData = try? Data(contentsOf: sourceURL) else {
            fatalError("Could not convert data")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
                
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        guard let weights = try? decoder.decode([BodyWeightModel].self, from: dataJSONData) else {
            fatalError("Must be a problem with the data")
        }
        
        for weight in weights {
            self.weights.append(weight)
        }
        
        
        
    }
    
    func setTestWeight() {
        
    }
}
