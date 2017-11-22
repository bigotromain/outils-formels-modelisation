extension PredicateNet {

    /// Returns the marking graph of a bounded predicate net.
    public func markingGraph(from marking: MarkingType) -> PredicateMarkingNode<T>? {

      var transitions = Array(self.transitions)
      let m0 = PredicateMarkingNode<T>(marking: marking, successors: [:]) //Initialisation marquage initial
      var marquages_a_traiter = [m0]
      var marquages_traites = [m0]

      while (marquages_a_traiter.count != 0) { //Tant qu'il reste des marquages à traiter

        let current_marquage = marquages_a_traiter[0] //On extrait un marquage des marquages_a_traiter pour le traiter

        for i in 0...(transitions.count-1) { // On va itérer sur toutes les transitions

          let array_bindings = transitions[i].fireableBingings(from: current_marquage.marking) //On récupère les bindings possibles
          var newBinding : PredicateBindingMap<T> = [:] //Initialisation d'une variable pour pouvoir l'ajouter comme successor

          for binding in array_bindings { //On va itérer sur les bindings possibles pour la transitions i

            if let new_shot = transitions[i].fire(from: current_marquage.marking, with: binding) { //Si le tire est possible (ici on obtient un marking)
              let new_marquage = PredicateMarkingNode<T>(marking: new_shot, successors: [:]) //on met notre nouveau marquage comme un PredicateMarkingNode

              if (marquages_traites.contains(where:{ PredicateNet.greater(new_marquage.marking, $0.marking)}) == true) { //Si on a un nouveau marquage plus grand le model est pas borné
                return nil //On arrête
              }
              if (marquages_traites.contains(where:{ PredicateNet.equals($0.marking, new_marquage.marking)}) == false) { //Si le nouveau marquage que l'on a trouvé n'est pas dans les marquages traités
                marquages_a_traiter.append(new_marquage) //On le met dans les marquages à traiter
                marquages_traites.append(new_marquage) //Et dans les marquages traités
                newBinding[binding] = new_marquage //on met notre nouveau marquage dans un binding avec le binding "binding"
                current_marquage.successors.updateValue(newBinding, forKey: transitions[i]) //on le met comme successor avec updateValue par la transition t[i]
              }
            }
          } //Fin de l'itération sur les bindings possibles
        } //Fin de l'itération sur toutes les transitions

      //print(current_marquage.marking)
      marquages_a_traiter.remove(at: 0) //Une fois qu'on a traité cet élément, on le retire des marquages à traiter

    } //Fin de la boucle while
      return m0
  } //fin de la fonction


    // MARK: Internals

    private static func equals(_ lhs: MarkingType, _ rhs: MarkingType) -> Bool {
        guard lhs.keys == rhs.keys else { return false }
        for (place, tokens) in lhs {
            guard tokens.count == rhs[place]!.count else { return false }
            for t in tokens {
                guard rhs[place]!.contains(t) else { return false }
            }
        }
        return true
    }

    private static func greater(_ lhs: MarkingType, _ rhs: MarkingType) -> Bool {
        guard lhs.keys == rhs.keys else { return false }

        var hasGreater = false
        for (place, tokens) in lhs {
            guard tokens.count >= rhs[place]!.count else { return false }
            hasGreater = hasGreater || (tokens.count > rhs[place]!.count)
            for t in rhs[place]! {
                guard tokens.contains(t) else { return false }
            }
        }
        return hasGreater
    }

}

/// The type of nodes in the marking graph of predicate nets.
public class PredicateMarkingNode<T: Equatable>: Sequence {

    public init(
        marking   : PredicateNet<T>.MarkingType,
        successors: [PredicateTransition<T>: PredicateBindingMap<T>] = [:])
    {
        self.marking    = marking
        self.successors = successors
    }

    public func makeIterator() -> AnyIterator<PredicateMarkingNode> {
        var visited = [self]
        var toVisit = [self]

        return AnyIterator {
            guard let currentNode = toVisit.popLast() else {
                return nil
            }

            var unvisited: [PredicateMarkingNode] = []
            for (_, successorsByBinding) in currentNode.successors {
                for (_, successor) in successorsByBinding {
                    if !visited.contains(where: { $0 === successor }) {
                        unvisited.append(successor)
                    }
                }
            }

            visited.append(contentsOf: unvisited)
            toVisit.append(contentsOf: unvisited)

            return currentNode
        }
    }

    public var count: Int {
        var result = 0
        for _ in self {
            result += 1
        }
        return result
    }

    public let marking: PredicateNet<T>.MarkingType

    /// The successors of this node.
    public var successors: [PredicateTransition<T>: PredicateBindingMap<T>]

}

/// The type of the mapping `(Binding) ->  PredicateMarkingNode`.
///
/// - Note: Until Conditional conformances (SE-0143) is implemented, we can't make `Binding`
///   conform to `Hashable`, and therefore can't use Swift's dictionaries to implement this
///   mapping. Hence we'll wrap this in a tuple list until then.
public struct PredicateBindingMap<T: Equatable>: Collection {

    public typealias Key     = PredicateTransition<T>.Binding
    public typealias Value   = PredicateMarkingNode<T>
    public typealias Element = (key: Key, value: Value)

    public var startIndex: Int {
        return self.storage.startIndex
    }

    public var endIndex: Int {
        return self.storage.endIndex
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public subscript(index: Int) -> Element {
        return self.storage[index]
    }

    public subscript(key: Key) -> Value? {
        get {
            return self.storage.first(where: { $0.0 == key })?.value
        }

        set {
            let index = self.storage.index(where: { $0.0 == key })
            if let value = newValue {
                if index != nil {
                    self.storage[index!] = (key, value)
                } else {
                    self.storage.append((key, value))
                }
            } else if index != nil {
                self.storage.remove(at: index!)
            }
        }
    }

    // MARK: Internals

    private var storage: [(key: Key, value: Value)]

}

extension PredicateBindingMap: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: ([Variable: T], PredicateMarkingNode<T>)...) {
        self.storage = elements
    }

}
