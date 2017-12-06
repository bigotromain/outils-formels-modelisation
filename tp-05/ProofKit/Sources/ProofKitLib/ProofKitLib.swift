infix operator =>: LogicalDisjunctionPrecedence

public protocol BooleanAlgebra {

    static prefix func ! (operand: Self) -> Self
    static        func ||(lhs: Self, rhs: @autoclosure () throws -> Self) rethrows -> Self
    static        func &&(lhs: Self, rhs: @autoclosure () throws -> Self) rethrows -> Self

}

extension Bool: BooleanAlgebra {}

public enum Formula {

    /// p
    case proposition(String)

    /// ¬a
    indirect case negation(Formula)

    public static prefix func !(formula: Formula) -> Formula {
        return .negation(formula)
    }

    /// a ∨ b
    indirect case disjunction(Formula, Formula)

    public static func ||(lhs: Formula, rhs: Formula) -> Formula {
        return .disjunction(lhs, rhs)
    }

    /// a ∧ b
    indirect case conjunction(Formula, Formula)

    public static func &&(lhs: Formula, rhs: Formula) -> Formula {
        return .conjunction(lhs, rhs)
    }

    /// a → b
    indirect case implication(Formula, Formula)

    public static func =>(lhs: Formula, rhs: Formula) -> Formula {
        return .implication(lhs, rhs)
    }

    /// The negation normal form of the formula.
    public var nnf: Formula {
        switch self {
        case .proposition(_):
            return self
        case .negation(let a):
            switch a {
            case .proposition(_):
                return self
            case .negation(let b):
                return b.nnf
            case .disjunction(let b, let c):
                return (!b).nnf && (!c).nnf
            case .conjunction(let b, let c):
                return (!b).nnf || (!c).nnf
            case .implication(_):
                return (!a.nnf).nnf
            }
        case .disjunction(let b, let c):
            return b.nnf || c.nnf
        case .conjunction(let b, let c):
            return b.nnf && c.nnf
        case .implication(let b, let c):
            return (!b).nnf || c.nnf
        }
    }
//////////////////////////////////IMPLEMENTATION////////////////////////////////

    ////////////////////DNF///////////////////////
    /// The disjunctive normal form of the formula.
    public var dnf: Formula {

        switch self.nnf { //On se sert de la NNF pour créer la DNF.

          //Conditions d'arrêt.
          case .proposition(_): //Si on a une proposition, on arrête.
            return self.nnf
          case .negation(_): //Si on a une negation, on arrête.
            return self.nnf

          case .disjunction(let a, let b):  //Si on a une disjunction alors on va traiter LE RHS et LHS.
            return a.dnf || b.dnf //On traite les deux cas

          case .conjunction(let a, let b): //Si on a une conjonction, il va falloir développer jusqu'à avoir une disjonction.
            //On ne testera pas sur les LHS & RHS si ce sont des conjonctions ou autres puisqu'on appelle la fonction
            //récursivement et que l'on fait déjà ces tests plus haut.

            switch a.dnf { //a est le terme de gauche de la conjonction (LHS)
              case .disjunction(let c, let d): //Si a, le LHS, est une disjonction, il va falloir le distribuer.
                return ((c.dnf && b.dnf) || (d.dnf && b.dnf)).dnf //On distribue + on appelle récursivement la fonction avec les nouveaux termes.
                default: break //Default case
              }

            switch b.dnf { //b est le terme de droite de la conjonction (RHS)
              case .disjunction(let c, let d): //Si b, le RHS, est une disjonction, il va falloir le distribuer.
                return ((c.dnf && a.dnf) || (d.dnf && a.dnf)).dnf //On distribue + on appelle récursivement la fonction avec les nouveaux termes.
                default: break //Default case
              }

          default : break //Default case.

        } //Fin du switch
      return self.nnf
    } //Fin de la fonction


    ////////////////////CNF///////////////////////
    /// The conjunctive normal form of the formula.
    public var cnf: Formula {

      switch self.nnf {

        //Conditions d'arrêt.
        case .proposition(_): //Si on a une proposition, on arrête.
          return self.nnf
        case .negation(_): //Si on a une negation, on arrête.
          return self.nnf

        case .conjunction(let a, let b): //Si on a une conjonction alors on va traiter LE RHS et LHS.
          return  a.cnf && b.cnf //On traite les deux cas

        case .disjunction(let a, let b): //Si on a une conjonction, il va falloir développer jusqu'à avoir une disjonction.
            //On ne testera pas sur les LHS & RHS si ce sont des disjunctions ou autres puisqu'on appelle la fonction
            //récursivement et que l'on fait déjà ces tests plus haut.

            switch a.cnf { //a est le terme de gauche de la conjonction (LHS)
            case .conjunction(let c, let d): //Si a est une conjunction
                return ((c.cnf || b.cnf) && (d.cnf || b.cnf)).cnf //On distribue (de manière inverse à la disjunction) + on appelle récursivement la fonction avec les nouveaux termes.
                default: break //Default case
              }

            switch b.cnf { //b est le terme de droite de la conjonction (RHS)
            case .conjunction(let c, let d): //Si b est un conjunction
                return ((c.cnf || a.cnf) && (d.cnf || a.cnf)).cnf //On distribue (de manière inverse à la disjunction) + on appelle récursivement la fonction avec les nouveaux termes.
                default: break //Default case
              }

          default : break //Default case.

    } //Fin du switch
    return self.nnf
  } //Fin de la fonction

//////////////////////////////////IMPLEMENTATION////////////////////////////////




    /// The propositions the formula is based on.
    ///
    ///     let f: Formula = (.proposition("p") || .proposition("q"))
    ///     let props = f.propositions
    ///     // 'props' == Set<Formula>([.proposition("p"), .proposition("q")])
    public var propositions: Set<Formula> {
        switch self {
        case .proposition(_):
            return [self]
        case .negation(let a):
            return a.propositions
        case .disjunction(let a, let b):
            return a.propositions.union(b.propositions)
        case .conjunction(let a, let b):
            return a.propositions.union(b.propositions)
        case .implication(let a, let b):
            return a.propositions.union(b.propositions)
        }
    }

    /// Evaluates the formula, with a given valuation of its propositions.
    ///
    ///     let f: Formula = (.proposition("p") || .proposition("q"))
    ///     let value = f.eval { (proposition) -> Bool in
    ///         switch proposition {
    ///         case "p": return true
    ///         case "q": return false
    ///         default : return false
    ///         }
    ///     })
    ///     // 'value' == true
    ///
    /// - Warning: The provided valuation should be defined for each proposition name the formula
    ///   contains. A call to `eval` might fail with an unrecoverable error otherwise.
    public func eval<T>(with valuation: (String) -> T) -> T where T: BooleanAlgebra {
        switch self {
        case .proposition(let p):
            return valuation(p)
        case .negation(let a):
            return !a.eval(with: valuation)
        case .disjunction(let a, let b):
            return a.eval(with: valuation) || b.eval(with: valuation)
        case .conjunction(let a, let b):
            return a.eval(with: valuation) && b.eval(with: valuation)
        case .implication(let a, let b):
            return !a.eval(with: valuation) || b.eval(with: valuation)
        }
    }

}

extension Formula: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .proposition(value)
    }

}

extension Formula: Hashable {

    public var hashValue: Int {
        return String(describing: self).hashValue
    }

    public static func ==(lhs: Formula, rhs: Formula) -> Bool {
        switch (lhs, rhs) {
        case (.proposition(let p), .proposition(let q)):
            return p == q
        case (.negation(let a), .negation(let b)):
            return a == b
        case (.disjunction(let a, let b), .disjunction(let c, let d)):
            return (a == c) && (b == d)
        case (.conjunction(let a, let b), .conjunction(let c, let d)):
            return (a == c) && (b == d)
        case (.implication(let a, let b), .implication(let c, let d)):
            return (a == c) && (b == d)
        default:
            return false
        }
    }

}

extension Formula: CustomStringConvertible {

    public var description: String {
        switch self {
        case .proposition(let p):
            return p
        case .negation(let a):
            return "¬\(a)"
        case .disjunction(let a, let b):
            return "(\(a) ∨ \(b))"
        case .conjunction(let a, let b):
            return "(\(a) ∧ \(b))"
        case .implication(let a, let b):
            return "(\(a) → \(b))"
        }
    }

}
