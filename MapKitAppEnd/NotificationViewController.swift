//
//  NotificationViewController.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 21.02.2024.
//

import Foundation
import UIKit
import UserNotifications

class NotificationViewController: UIViewController, UNUserNotificationCenterDelegate, UIAdaptivePresentationControllerDelegate {

    
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

        // DatePicker eklendi
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // "Send Notification" butonu eklendi
        let sendNotificationButton = UIButton(type: .system)
        sendNotificationButton.setTitle("Hatırlatıcı", for: .normal)
        sendNotificationButton.setTitleColor(.white, for: .normal)
        sendNotificationButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        sendNotificationButton.backgroundColor = .systemBlue
        sendNotificationButton.layer.cornerRadius = 5
        sendNotificationButton.frame = CGRect(x: 70, y: 70, width: 600, height: 400)
        sendNotificationButton.addTarget(self, action: #selector(kontrolVeBildirimGonder), for: .touchUpInside)
        view.addSubview(sendNotificationButton)

        // Butonun konumu için constraint'ler eklendi
        sendNotificationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendNotificationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendNotificationButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20)
        ])

        // Arka plan rengi ve diğer ayarlar yapıldı
        self.view.backgroundColor = UIColor.white

        // İzin kontrolü ve bildirim merkezi delegesi ayarlandı
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

