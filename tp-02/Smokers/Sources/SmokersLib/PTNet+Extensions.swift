//BIGOT ROMAIN

import PetriKit

public class MarkingGraph {

    public let marking   : PTMarking
    public var successors: [PTTransition: MarkingGraph]

    public init(marking: PTMarking, successors: [PTTransition: MarkingGraph] = [:]) {
        self.marking    = marking
        self.successors = successors
    }

}

public extension PTNet {

    public func markingGraph(from marking: PTMarking) -> MarkingGraph? {

        let transitions_array = Array(transitions) //Extraction des transitions sous forme d'array pour pouvoir parcourir chacune des transitions
        var m0 = MarkingGraph(marking: marking, successors: [:])
        var marquages_a_traiter = [m0] //On va lister les marquages à traiter, ca va être la condition d'arrêt
        var marquages_traites = [m0] //On va lister les marquages traités dans cette array
        var current = m0
        var tire_current = transitions_array[0].fire(from : m0.marking)


        while (marquages_a_traiter.count != 0) {

          current = marquages_a_traiter[0] //current working marquage

          for i in 0...(transitions_array.count-1) { //Pour toutes les transitions

            if (transitions_array[i].fire(from : current.marking) != nil) { //Si la transition est tirable

              tire_current = transitions_array[i].fire(from : current.marking) //On définit le tire
              var m1 = MarkingGraph(marking:tire_current!, successors: [:]) //et m1 avec comme marking le tire_current et des successors inconnus

              if is_in_array(array: marquages_traites, element: m1) == false { //Si m1 n'est pas dans les marquages traités
                marquages_traites.append(m1) //On le met dedans
                marquages_a_traiter.append(m1) //Ainsi que dans les marquages à traiter
                current.successors.updateValue(m1, forKey: transitions_array[i]) //On met m1 comme nouveau successor de current par la transition ti
              }

              if (m1.marking == current.marking) { //Si le marquage m1 est égal au marquage courant
              current.successors.updateValue(current, forKey: transitions_array[i]) //on le met comme successor
              }

            }

          } //Fin de la boucle FOR


          marquages_a_traiter.remove(at: 0) //Remove le current sur lequel on a déjà travailler

        } //Fin de la boucle WHILE => Il n'y a plus de marquages à traiter

       return m0
    }
}


//Fonction qui test si un element de type markinggraph est dans un array de markinggraph
//similaire à contains
func is_in_array(array: Array<MarkingGraph>, element: MarkingGraph) -> Bool {
  for i in 0...(array.count-1) {
    if (array[i].marking == element.marking) {
      return true
    }
  }
  return false
}
