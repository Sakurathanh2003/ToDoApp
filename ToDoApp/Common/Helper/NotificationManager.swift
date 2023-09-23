//
//  NotificationManager.swift
//  ColoringByPixel
//
//  Created by Linh Nguyen Duc on 13/10/2022.
//

import UIKit
import UserNotifications
import RxSwift

final class NotificationManager {
    static let kDidScheduledAdvertiseNotification = "didScheduledAdvertiseNotification"

    func isScheduledAdvertiseNotification() -> Bool {
        return UserDefaults.standard.bool(forKey: NotificationManager.kDidScheduledAdvertiseNotification)
    }

    func scheduleAdvertiseNotifications() {
        self.scheduleNotificationFrom2To6()
        UserDefaults.standard.set(true, forKey: NotificationManager.kDidScheduledAdvertiseNotification)
    }

    private func scheduleNotificationFrom2To6() {
        for weekDay in 2 ... 6 {
            let dateComponent1 = DateComponents(hour: 20, minute: 30, weekday: weekDay)
            self.scheduleNotification(content: self.randomContent(), dateComponent: dateComponent1)
        }
    }

    private func scheduleNotification(content: (String, String), dateComponent: DateComponents) {
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let mutableNotificationContent = UNMutableNotificationContent()
        mutableNotificationContent.title = content.0
        mutableNotificationContent.body = content.1
        mutableNotificationContent.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: mutableNotificationContent, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    private func randomContent() -> (String, String) {
        let contents = [
            ["Stickman Mania! Unleash Your Inner Animator Today!", "Ready for some creative fun? Use our animation creator to bring your stick figures to life!"],
            ["Get Your Stick Together!", "Bored at home? Let your imagination run wild and create hilarious animations with our manga maker tools!"],
            ["You're the Picasso of Stick Figures!", "Who says you need to be a pro artist to make animations? With our animation creator, you'll be the Michelangelo of stick figures in no time!"],
            ["Be an Animator, Not a Potato!", "Tired of being a potato on the couch? Get creative and make your own animations with Stickman Animation Maker!"],
            ["Make Your Stickman Come to Life!", "It's time to put your animation skills to the test! Let's bring your stickman to life!"],
            ["Get Your Daily Dose of Laughter with Stickman Animation!", "Feeling bored? Let's create your own fun videos!"],
            ["Bedtime Boredom? Let Stickman Animation Save the Night!", "Don't let boredom keep you up at night!"],
            ["Tired of Netflix? Create Your Own Entertainment with Stickman Animation 🎬", "Why spend the evening scrolling through Netflix when you can create your own animated fun!"],
            ["Don't Let Your Day Be Flat!", "It's never too late to add some fun to your day! Enjoy the features of our app!"],
            ["Don't Just Netflix and Chill, Animate and Thrill 🤭", "Who needs sleep when you can create hilarious animations with our animation creator!"],
        ]

        let element = contents.randomElement()!
        return (element[0], element[1])
        // Sun, Sat, Fri
//        if dateComponent.weekday == 1 || dateComponent.weekday == 7 || dateComponent.weekday == 6 {
//            if dateComponent.hour == 10 {
//                return [
//                    "Boost your mood for a new good day with this beautiful picture!",
//                    "Your daily bible verse picture is ready! Start now!",
//                    "Here's your bible picture of the day, let's color and pray!"
//                ]
//            }
//
//            return [
//                "Time to relax! Let's color now!",
//                "Paint this artwork & keep connect to God!",
//                "Updated new amazing holy picture! Don't miss it!",
//                "Finish the stories in the Bible! Click here!"
//            ]
//        }
//
//        if dateComponent.hour == 7 {
//            return [
//                "Let's color and pray now for a nice day!",
//                "Color this beautiful picture and boost your mood for a new good day",
//                "Stay believe and paint these amazing artworks!",
//                "Pray for your loved ones and have a good time together with holy pictures!"
//            ]
//        }
//
//        return [
//            "Color now and release your stress away!",
//            "Newly updated beautiful artwork for you to get relaxed. Let's find out!",
//            "Improve your sleep & keep connect to God!",
//            "Color these bible pictures with your loved ones and keep connected to God!"
//        ]
    }
}
