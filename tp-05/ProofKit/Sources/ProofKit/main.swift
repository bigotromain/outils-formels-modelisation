import ProofKitLib

let a: Formula = "a"
let b: Formula = "b"
let c: Formula = "c"


var f = !(a => (b && c))
print("\n")
print("TEST 1 :")
print("Initial formula : ", f)
print("Negation Normal Form : ", f.nnf)
print("Disjunction Normal Form : ", f.dnf)
print("Conjunctive Normal Form : ", f.cnf)


f = (a => b)
print("\n")
print("TEST 2 :")
print("Initial formula : ", f)
print("Negation Normal Form : ", f.nnf)
print("Disjunctive Normal Form : ", f.dnf)
print("Conjunctive Normal Form : ", f.cnf)

f = !a || (b && !c)
print("\n")
print("TEST 3 :")
print("Initial formula : ", f)
print("Negation Normal Form : ", f.nnf)
print("Disjunctive Normal Form : ", f.dnf)
print("Conjunctive Normal Form : ", f.cnf)







/////////////////////PAS UTUILISé POUR LES TESTS////////////////////////////////
// let booleanEvaluation = f.eval { (proposition) -> Bool in
//     switch proposition {
//         case "p": return true
//         case "q": return false
//         default : return false
//     }
// }
// print(booleanEvaluation)

// enum Fruit: BooleanAlgebra {
//
//     case apple, orange
//
//     static prefix func !(operand: Fruit) -> Fruit {
//         switch operand {
//         case .apple : return .orange
//         case .orange: return .apple
//         }
//     }
//
//     static func ||(lhs: Fruit, rhs: @autoclosure () throws -> Fruit) rethrows -> Fruit {
//         switch (lhs, try rhs()) {
//         case (.orange, .orange): return .orange
//         case (_ , _)           : return .apple
//         }
//     }
//
//     static func &&(lhs: Fruit, rhs: @autoclosure () throws -> Fruit) rethrows -> Fruit {
//         switch (lhs, try rhs()) {
//         case (.apple , .apple): return .apple
//         case (_, _)           : return .orange
//         }
//     }
//
// }
//
// let fruityEvaluation = f.eval { (proposition) -> Fruit in
//     switch proposition {
//         case "p": return .apple
//         case "q": return .orange
//         default : return .orange
//     }
// }
// print(fruityEvaluation)
