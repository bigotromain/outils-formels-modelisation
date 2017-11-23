//BIGOT ROMAIN

import PetriKit
import PhilosophersLib

//EXEMPLE DU COURS
// do {
//     enum C: CustomStringConvertible {
//         case b, v, o
//
//         var description: String {
//             switch self {
//             case .b: return "b"
//             case .v: return "v"
//             case .o: return "o"
//             }
//         }
//     }
//
//     func g(binding: PredicateTransition<C>.Binding) -> C {
//         switch binding["x"]! {
//         case .b: return .v
//         case .v: return .b
//         case .o: return .o
//         }
//     }
//
//     let t1 = PredicateTransition<C>(
//         preconditions: [
//             PredicateArc(place: "p1", label: [.variable("x")]),
//         ],
//         postconditions: [
//             PredicateArc(place: "p2", label: [.function(g)]),
//         ])
//
//     let m0: PredicateNet<C>.MarkingType = ["p1": [.b, .b, .v, .v, .b, .o], "p2": []]
//     guard let m1 = t1.fire(from: m0, with: ["x": .b]) else {
//         fatalError("Failed to fire.")
//     }
//     print(m1)
//     guard let m2 = t1.fire(from: m1, with: ["x": .v]) else {
//         fatalError("Failed to fire.")
//     }
//     print(m2)
// }

do {


    //Question 1
    print("Question 1 :")
    let philosophers_nonbloquable = lockFreePhilosophers(n: 5)
    let markingGraph = philosophers_nonbloquable.markingGraph(from : philosophers_nonbloquable.initialMarking!)
    print("Nombre de marquages possibles dans le modèle des philosophes non bloquable à 5 philosophes :", markingGraph!.count)
    print()
    //Question 2
    print("Question 2 :")
    let philosophers_bloquable = lockablePhilosophers(n: 5)
    let markingGraph2 = philosophers_bloquable.markingGraph(from : philosophers_bloquable.initialMarking!)
    print("Marquages possibles dans le modèle des philosophes bloquable à 5 philosophes :", markingGraph2!.count)

    //Question 3
    for node in markingGraph2! {
      if (node.successors.count == 0) {    //Réseau bloqué : plus aucune transition n'est tirable -> plus aucun successors pour le current node
        print("Etat où le réseau est en bloquage : ", node.marking)
        break;
      }
    }
    print("Cet état bloquant est : Tous les philosophes ont pris leur fourchette gauche (ou tous ont pris la droite) et tous attendent leur deuxième pour pouvoir manger. On obtient donc un deadlock.")

}
