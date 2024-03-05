//
//  NotificationViewController.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 21.02.2024.
//

import Foundation
import UIKit
import UserNotifications

class NotificationViewController: UIViewController, UNUserNotificationCenterDelegate {

    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = .current
        datePicker.timeZone = .current
        datePicker.datePickerMode = .time
        datePicker.tintColor = .systemOrange
        datePicker.backgroundColor = .white
        datePicker.layer.borderWidth = 1
        datePicker.layer.cornerRadius = 8
        
        return datePicker
    }()
    
    var estimatedTime : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(datePicker)
        datePicker.center = view.center
        
        // Buton ekleyerek bildirim gönderme işlemi başlatılabilir
        let sendNotificationButton = UIButton(type: .system)
        sendNotificationButton.setTitle("Send Notification", for: .normal)
        
       sendNotificationButton.setTitleColor(.white, for: .normal)
       
        sendNotificationButton.backgroundColor = .systemBlue // Butonun arkaplan rengini belirle
        sendNotificationButton.layer.cornerRadius = 10 // Butona köşe yuvarlaklığı ekle
        sendNotificationButton.addTarget(self, action: #selector(kontrolVeBildirimGonder), for: .touchUpInside)
        sendNotificationButton.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        sendNotificationButton.center = CGPoint(x: view.center.x, y: view.center.y + 50)
        view.addSubview(sendNotificationButton)
        
        checkForPermission()
        UNUserNotificationCenter.current().delegate = self
   
       
        
       

             
    }
    
    func calculateEstimatedTime() -> Int {
        
        let estimatedTime = 1 // Örnek olarak 1 dakika
        return estimatedTime
    }
    
    @objc func kontrolVeBildirimGonder() {
        // 1.adım : saat seç
        var selectedDate = datePicker.date
        print(datePicker.date.description(with: .current))
        print("Selected Date: \(selectedDate)")
        
        // 2.adım tahmini kaç dakika hesaplanması
        // örnek : 1 dakika
        let tahminiSure = self.estimatedTime
        // 3.adım yola cıkmak için gereken zamanı hesapla
        // Tahmini süreyi seçili saatten çıkartarak hedef saati hesapla
        let cikisZaman = selectedDate.addingTimeInterval(-Double(tahminiSure)*60)

        print("cikisZamani: \(cikisZaman)")
        print("hedeflenen Saat: \(selectedDate)")
        
        //cikis zamanina notification gönder
        sendNotification(date: cikisZaman)
    }
    
    private func sendNotification(date: Date) {
        let selectedDate = date
        let content = UNMutableNotificationContent()
        content.title = "Yola çıkma vakti!"
        content.body = "Hedef için şimdi yola çıkmalısın!"
        content.sound = .default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: selectedDate)
        print("Notification gönderilecek tarih saat: \(selectedDate)")
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully!")
            }
        }
    }

    
    func checkForPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("Notification permission authorized")
            case .denied:
                print("Notification permission denied")
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        print("Notification permission granted")
                    } else {
                        print("Notification permission denied")
                    }
                }
            default:
                break
            }
        }
    }
    
    // Bildirim alındığında çağrılır
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Kullanıcının bildirime tıklaması durumunda gerçekleştirilecek işlemleri burada belirtebilirsiniz
        print("Notification received: \(response.notification.request.content.title)")
        completionHandler()
    }
}
