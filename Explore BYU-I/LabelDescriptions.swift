//
//  LabelDescriptions.swift
//  Explore BYU-I
//
//  Created by happyPenguinMac on 05/03/20.
//  Copyright © 2020 Kevin Foniciello. All rights reserved.
//

import Foundation

/**
 *   In the real world, the data bellow would have been
 *   downloaded from the web in some sort of JSON file
 *   and stored in the IOS Core Data. Here all we need
 *   to do is extract the data from the Core data and display it
 */
class LabelDescriptions : Identifiable {
    var id = UUID()
    private var labels = [
        "Banana" :    Description(
            headline: "Banana",
            subheadline: "About the Banana",
            body: "A banana is an edible fruit – botanically a berry – produced by several kinds of large herbaceous flowering plants in the genus Musa. In some countries, bananas used for cooking may be called \"plantains\", distinguishing them from dessert bananas."
        ),
        "Egg" :       Description(
            headline: "Egg",
            subheadline: "About the Egg",
            body: "Some eggs are laid by female animals of many different species, including birds, reptiles, amphibians, mammals, and fish, and have been eaten by humans for thousands of years. Bird and reptile eggs consist of a protective eggshell, albumen, and vitellus, contained within various thin membranes."
        ),
        "Waffle" :    Description(
            headline: "Waffle",
            subheadline: "About the Waffle",
            body: "A waffle is a dish made from leavened batter or dough that is cooked between two plates that are patterned to give a characteristic size, shape, and surface impression. There are many variations based on the type of waffle iron and recipe used."
        ),
        "Coffee" :    Description(
            headline: "Coffee",
            subheadline: "About the Coffee",
            body: "Coffee is a brewed drink prepared from roasted coffee beans, the seeds of berries from certain Coffea species. The genus Coffea is native to tropical Africa and Madagascar, the Comoros, Mauritius, and Réunion in the Indian Ocean."
        ),
        "Croissant" : Description(
            headline: "Croissant",
            subheadline: "About the Croissant",
            body: "A croissant is a buttery, flaky, viennoiserie pastry of Austrian origin, named for its historical crescent shape. Croissants and other viennoiserie are made of a layered yeast-leavened dough."
        )
    ]
    
    public func get(label: String) -> Description {
        return labels[label, default: Description(headline: "Could not detect landmark", subheadline: "Try another angle or moving closer", body: "")]
    }
}
