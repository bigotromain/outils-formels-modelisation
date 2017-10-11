//BIGOT Romain - TP1 Outils formels de Modélisation

import TaskManagerLib

let taskManager = createTaskManager()

//Importons les places
var taskPool = taskManager.places.first { $0.name == "taskPool" }!
var exec = taskManager.transitions.first { $0.name == "exec" }!
var inProgress  = taskManager.places.first { $0.name == "inProgress" }!
var create = taskManager.transitions.first { $0.name == "create" }!
var processPool = taskManager.places.first { $0.name == "processPool" }!
var spawn = taskManager.transitions.first { $0.name == "spawn" }!
var success = taskManager.transitions.first { $0.name == "success" }!

//La suite d'exécutions suivante va conduire à un problème :
print("En utilisant le réseau proposé :")
var m1 = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0]) //Création d'une nouvelle tâche 1
var m2 = spawn.fire(from: m1!) //Création d'un nouveau processus 1
var m3 = exec.fire(from: m2!) //Exécution de ce processus & tâche
var m4 = spawn.fire(from: m3!) //Spawn d'un nouveau processus 2
var m5 = exec.fire(from: m4!) //Exécution de ce processus 2 avec la tâche 1
var m6 = success.fire(from: m5!) //On success le processus 2 et la tâche 1
print(m6!,"\n")
//Ici on voit qu'il y a maintenant processus 1 bloqué dans la place "in progress"
//Cela signifie qu'il n'a pas été détruit malgré qu'il ait fini d'exécuter sa tâche. On a donc bien notre problème.



//On va maintenant corriger le problème en corrigeant le réseau
var correctTaskManager = createCorrectTaskManager()

taskPool = correctTaskManager.places.first { $0.name == "taskPool" }!
success = correctTaskManager.transitions.first { $0.name == "success" }!
inProgress = correctTaskManager.places.first { $0.name == "inProgress" }!
create = correctTaskManager.transitions.first { $0.name == "create" }!
spawn = correctTaskManager.transitions.first { $0.name == "spawn" }!
processPool = correctTaskManager.places.first { $0.name == "processPool" }!
exec = correctTaskManager.transitions.first { $0.name == "exec" }!
var FreeProcess = correctTaskManager.places.first { $0.name == "FreeProcess"}! //Création d'une nouvelle place
//Cette place a un jeton initialement dedans
//Il y a un arc qui part de FreeProcess vers exec.
//success & fail ont un arc qui se dirige vers celle-ci. Cela permet de s'assurer que
//il faut que le processus "in progress" ait finit et donne un réponse de type success ou fail
//Ainsi un nouveau jeton sera mis dans FreeProcess et donc un nouveau couple (tâche,processus)
//pourra être exécuter.



m1 = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0, FreeProcess: 1]) //Création d'une nouvelle tâche
m2 = spawn.fire(from: m1!) //spawn d'un nouveau processus 1
m3 = exec.fire(from: m2!) //exécution du processus & tâche
m4 = spawn.fire(from: m3!) //spawn d'un nouveau processus 2
print(m4!) //Print de l'état du système avant l'erreur
if (exec.fire(from: m4!) == nil) { //Tentative d'exécuter la tâche précédente avec le nouveau processus 2
  print("Erreur, un processus est en cours d'exécution") //Impossible car on a besoin d'un jeton dans FreeProcess
}
//Il faut donc que la personne tire si le processus a échoué ou réussi.
//Ainsi on aura de nouveau un jeton disponible dans FreeProcess et on va pouvoir
//exécuter de nouvelles tâches.
//Le problème est donc résolu.
