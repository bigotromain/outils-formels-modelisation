//BIGOT ROMAIN

import PetriKit

public extension PTNet {

    public func coverabilityGraph(from marking: CoverabilityMarking) -> CoverabilityGraph {

      //Initialisation des variables
      var final_coverability = CoverabilityGraph(marking : marking)
      var marquages_a_traiter = [final_coverability]
      var marquages_traites = [CoverabilityGraph]()
      let transitions_array = Array(self.transitions) //On va itérer sur cette array des transitions
      //On aurait aussi pu itérer de la manière suivante: for transitions in self.transitions mais je trouve ça moins clair

      while let current = marquages_a_traiter.popLast() { //Tant qu'il reste des marquages à traiter

          let m1 = COVERtoPT(from: current.marking)
          for i in 0...(transitions_array.count-1) { //Pour toutes les transitions

            if let tire_current = transitions_array[i].fire(from: m1) { //Si la transition est tirable

              var m = PTtoCOVER(from: tire_current) //m est un coverabilityMarking depuis le tire du current

              for old_markings in final_coverability {
                if m > old_markings.marking { //Si le marquage m est plus grand qu'un ancien marquage
                  for p in self.places{
                    if m[p]! > old_markings.marking[p]! { //On cherche la place qui est > que l'ancien marquage
                      m[p] = .omega //On met omega à la place plus grande que cet ancien marquage
                      }
                    }
                  }
                }

                if marquages_a_traiter.contains(where: {$0.marking == m}) { //Si m est dans les marquages_a_traiter
                  current.successors.updateValue(marquages_a_traiter.first(where: {$0.marking == m})!, forKey: transitions_array[i]) //On le met comme successor du current par la transition t[i]
                }
                else if marquages_traites.contains(where: {$0.marking == m}) { //Sinon si m est dans les marquages_traites
                  current.successors.updateValue(marquages_traites.first(where: {$0.marking == m})!, forKey: transitions_array[i]) //On le met comme successor du current par la transition t[i]
                }
                else { //Si il n'existe pas on le crée et on le met dans les marquages à traiter
                  let new_marquage = CoverabilityGraph(marking : m)
                  marquages_a_traiter.append(new_marquage)
                  current.successors.updateValue(new_marquage, forKey: transitions_array[i]) //On le met comme successor de current
                }
              }
            } //Fin de la boucle for sur les transitions

            marquages_traites.append(current) //On a traité ce marquage donc on le met dans marquages_traites
        } //Fin de la boucle while

      return final_coverability //Fin de la fonction

  }

    //FONCTIONS EXTERNES

    public func COVERtoPT(from marking: CoverabilityMarking) -> PTMarking {    // pour pouvoir tirer des transitions je crée un PTMarking correspondant au CoverabilityMarking current.marking

      var mark : PTMarking = [:] //On initialise un PTMarking
      for p in self.places { //On itère sur les places

        mark[p] = 500
        for i in 0...500 {
          if UInt(i) == marking[p]!{ //Si on a un UInt
            mark[p] = UInt(i) //On set comme un UInt
          }
        }
      }
      return mark //Fin de la fonction, on retourne notre marking converti
    }

    public func PTtoCOVER(from marking: PTMarking) -> CoverabilityMarking { //Fonction pour convertir un PTMarking en CoverabilityMarking

      var mark : CoverabilityMarking = [:]  //On initialise un CoverabilityMarking
      for p in self.places {

        if marking[p]! < 500 {
          mark[p] = .some(marking[p]!) //On a un UInt dans ce cas
        }
        else {
          mark[p] = .omega //Sinon on met un omega
        }
      }
      return mark //Fin de la fonction, on retourne notre marking converti
    }
}
