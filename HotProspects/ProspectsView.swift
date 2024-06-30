//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Gamıd Khalıdov on 28.06.2024.
//

import CodeScanner
import SwiftUI
import SwiftData

struct ProspectsView: View {
    
    @Query(sort: \Prospect.name) var prospects: [Prospect]
    @Environment(\.modelContext) var modelContext
    
    @State var isShowingScanner = false
    
    @State private var selectedProspects = Set<Prospect>()
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    let filter: FilterType
    
    var title: String {
        switch filter {
        case .none:
            "Everyone"
        case .contacted:
            "Contacted people"
        case .uncontacted:
            "Uncontacted people"
        }
    }
    
    var body: some View {
        NavigationStack {
            List(prospects, selection: $selectedProspects) { prospect in
                HStack{
                    VStack(alignment: .leading) {
                        Text(prospect.name)
                            .font(.headline)
                        Text(prospect.emailAddress)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if filter == .none{
                        Image(systemName: prospect.isContacted ? "phone.circle.fill" : "phone.circle")
                            .font(.title)
                    }
                }
                .swipeActions {
                    
                    Button("Delete", systemImage: "trash") {
                        modelContext.delete(prospect)
                    }
                    .tint(.red)
                    
                    if prospect.isContacted {
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark") {
                            prospect.isContacted.toggle()
                        }
                        .tint(.blue)
                    } else {
                        Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark") {
                            prospect.isContacted.toggle()
                        }
                        .tint(.green)
                        
                        Button("Remind me to contact", systemImage: "bell") {
                            addNotification(for: prospect)
                        }.tint(.orange)
                    }
                }
                .tag(prospect)
            }
            .navigationTitle(title)
            .toolbar {
                
                ToolbarItem(placement: .topBarTrailing){
                    Button("Scan", systemImage: "qrcode.viewfinder") {
                        isShowingScanner = true
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                if selectedProspects.isEmpty == false {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Delete selected", role: .destructive, action: delete)
                    }
                }
                
            }
            .sheet(isPresented: $isShowingScanner){
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan(result:))
            }
            
            
        }
    }
    
    init(filter: FilterType) {
        self.filter = filter

        if filter != .none {
            let showContactedOnly = filter == .contacted
            
            _prospects = Query(filter: #Predicate { prospect in
                prospect.isContacted == showContactedOnly
            }, sort: [SortDescriptor(\Prospect.name)])

        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
       isShowingScanner = false
       
        switch result {
        case .success(let success):
            let details = success.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let prospect = Prospect(name: details[0], emailAddress: details[1], isContacted: false)
            
            modelContext.insert(prospect)
            
        case .failure(let failure):
            print("something went wrong \(failure.localizedDescription)")
        }
    }
    
    func delete() {
        for selectedProspect in selectedProspects {
            modelContext.delete(selectedProspect)
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current() // Создаем сущность UNUserNotificationCenter (центр уведомлений)
        
        let addRequest = {
            let content = UNMutableNotificationContent() // Cоздаем сущность Для контента уведомления
            content.title = prospect.name
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default // задаем контент для уведомления
            
//            var dateComponents = DateComponents()
//            dateComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false) // указываем когда будет отправляться уведомление. в этом случае оно отправиться в 9 часов единожды
//
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // Тестово задаем интервал в 5 секунд, для того чтобы уведомление пришло через 5 секунд после вызова функции
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger) // создаем NotificationRequest чтобы дальше передать его в центр уведомлений.
            center.add(request) // Передаем запрос в центр уведомлений.
            
        }
        
        center.getNotificationSettings { settings in // проверяем текущие настройки уведомлений.
            if settings.authorizationStatus == .authorized { // если текущее состояние настроек уведомлений позволяет отправить уведомление отправляем запрос в нотификейшн центр
                addRequest()
            } else { // если настройки не позволяют отправить уведомление то:
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in // просим пользователя дать разрешение на отправку уведомлений. указываем параметры .alert - запрос на отправку плашки, .badge - на отправку банера, .sound - запрос на уведомления со звуком.
                    if success { // если пользователь дал доступ отправляем уведомление в центр
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
}

#Preview {
    ProspectsView(filter: .none)
}
