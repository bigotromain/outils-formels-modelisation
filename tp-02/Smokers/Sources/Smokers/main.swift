//BIGOT ROMAIN

import PetriKit
import SmokersLib

// Instantiate the model.
let model = createModel()

// Retrieve places model.
guard let r  = model.places.first(where: { $0.name == "r" }),
      let p  = model.places.first(where: { $0.name == "p" }),
      let t  = model.places.first(where: { $0.name == "t" }),
      let m  = model.places.first(where: { $0.name == "m" }),
      let w1 = model.places.first(where: { $0.name == "w1" }),
      let s1 = model.places.first(where: { $0.name == "s1" }),
      let w2 = model.places.first(where: { $0.name == "w2" }),
      let s2 = model.places.first(where: { $0.name == "s2" }),
      let w3 = model.places.first(where: { $0.name == "w3" }),
      let s3 = model.places.first(where: { $0.name == "s3" })
else {
    fatalError("invalid model")
}

// Create the initial marking.
let initialMarking: PTMarking = [r: 1, p: 0, t: 0, m: 0, w1: 1, s1: 0, w2: 1, s2: 0, w3: 1, s3: 0]

let transitions = model.transitions //Extraction des transitions

///FONCTION POUR ANALYSER UN MARKINGGRAPH ET ENUMERER LES NODES DANS SEEN
func countNodes(markingGraph: MarkingGraph) -> Array<MarkingGraph> {

  var seen = [markingGraph]
  var toVisit = [markingGraph]

  while let current = toVisit.popLast() {
    for (_, successor) in current.successors {
      if !seen.contains(where: { $0 === successor }) {
        seen.append(successor)
        toVisit.append(successor)
      }
    }
  }
  return seen
}

//FONCTION QUI VA FAIRE LE TEST DES 2 SMOKERS EN MÊME TEMPS
func twoSmokers(markingGraph: MarkingGraph) -> Bool {

  var seen = [markingGraph]
  var toVisit = [markingGraph]

  while let current = toVisit.popLast() {
    for (_, successor) in current.successors {
      if !seen.contains(where: { $0 === successor }) {
        seen.append(successor)
        toVisit.append(successor)
        //On parcourt le markingGraph et on regarde si il existe un marking avec deux fumeurs différents qui fument en même temps
        if ((successor.marking[s1] == 1 && successor.marking[s2] == 1) || (successor.marking[s1] == 1 && successor.marking[s3] == 1) || (successor.marking[s2] == 1 && successor.marking[s3] == 1)) {
          return true
        }
      }
    }
  }
  return false
}

//FONCTION QUI VA TESTER SI UN INGREDIENT PEUT APPARAITRE DEUX FOIS SUR LA TABLE
func twoIngredients(markingGraph: MarkingGraph) -> Bool {

  var seen = [markingGraph]
  var toVisit = [markingGraph]

  while let current = toVisit.popLast() {
    for (_, successor) in current.successors {
      if !seen.contains(where: { $0 === successor }) {
        seen.append(successor)
        toVisit.append(successor)
        //On parcourt le markingGraph et on regarde si il existe un marking avec 2 fois le même ingrédient sur la table
        if (successor.marking[p] == 2 || successor.marking[m] == 2 || successor.marking[t] == 2) {
          return true
        }
      }
    }
  }
  return false
}


if let markingGraph = model.markingGraph(from: initialMarking) {

    let array_des_marquages = countNodes(markingGraph : markingGraph)

    //1. Combien d'états différents le réseau peut avoir :> print le nombre d'état du graphe de marquage
    print("Il y a", array_des_marquages.count, "états")

    // //2. 2 fumeurs différents fument en même temps : chercher un état t.q 2 fumeurs fument en même temps (s1=s2=1 ou s1=s3=1 ou s2=s3=1)
    if (twoSmokers(markingGraph: markingGraph) == true){
      print("Il est possible que 2 fumeurs différents fument en même temps")
    }
    else{
      print("Il n'est pas possible que 2 fumeurs différents fument en même temps")
    }

    // //3. 2 fois le même ingrédient sur la table : chercher un état t.q (m=2 ou p=2 ou t=2)
    if (twoIngredients(markingGraph: markingGraph) == true){
      print("Il est possible qu'il y ait 2 fois le même ingrédient sur la table")
    }
    else{
      print("Ce n'est possible qu'il y ait 2 fois le même ingrédient sur la table")
    }
}
