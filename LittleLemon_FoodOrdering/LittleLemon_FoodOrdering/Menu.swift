//
//  Menu.swift
//  LittleLemon_FoodOrdering
//
//  Created by Sean Milfort on 3/22/23.
//

import SwiftUI

struct Menu: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var searchText = ""
    
    var body: some View {
        VStack{
            Text("Little Lemon Restaurant")
            Text("Chicago")
            Text("We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.")
            TextField("Search menu", text: $searchText)
            FetchedObjects(predicate: buildPredicate(),sortDescriptors: buildSortDescriptors()) { (dishes: [Dish]) in
                List {
                    if dishes.count != 0 {
                        ForEach(dishes, id: \.self) { dish in
                            HStack{
                                Text(dish.title! + " " + dish.price!)
                                AsyncImage(url: URL(string: dish.image!)) {image in image.resizable().frame(width: 100, height: 100)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    }
                }
            }
        }.onAppear{getMenuData()}
    }
    
    func getMenuData() {
        PersistenceController.shared.clear()
        
        let url = "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json"
        let URLData = URL(string: url)!
        let request = URLRequest(url: URLData)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data {
                let jsonDecoder = JSONDecoder()
                let decoded = try? jsonDecoder.decode( MenuList.self, from: data)
                if let decoded {
                    for menuItem in decoded.menu {
                        let dish = Dish(context: viewContext)
                        dish.title = menuItem.title
                        dish.price = menuItem.price
                        dish.image = menuItem.image
                    }
                    try? viewContext.save()
                }
                
            }
        }
            task.resume()
        }
    
    func buildSortDescriptors () -> [NSSortDescriptor] {
        return [NSSortDescriptor (key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare))]
    }
    
    func buildPredicate() -> NSPredicate {
        if searchText.isEmpty {
            return NSPredicate(value: true)
        } else {
            return NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        }
    }
}
    

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}
