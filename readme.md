<h1 align="center"> Simulation de comportement d’une vache
a l’aide d’un processus markovien </h1> <br>


## Table des matières

- [Introduction](#introduction)
- [Arborescence](#arborescence)
- [Données](#données)
- [Fichiers exécutables](#fichiers-exécutables)

## Introduction

Le jeu de données utilisé est le dataset LongHealth de Herbipole

L'ensemble des fichiers et des fonctions permet d'établir des modèles de Markov adaptés à chaque vache, d'en faire des simulations, et de comparer les résultats. Les codes sont réalisés sous le langage Matlab. Hormis *affichage.m*, les fichiers script écrivent les résultats dans le dossier *Dataprocess/*. Il est possible dans chaque script de modifier la valeur du paramètre *saveresults* pour ne pas faire la sauvegarde.

## Arborescence
* /Data/ : Emplacement des données
    * dataset1-1.csv, mainActivity_all.csv : jeux de données issus de la ferme expérimentale Herbipôle
    * mainActivity_filtered.csv : similaire à mainActivity_all.csv mais filtré pour être plus manipulable
    * CorrespondanceActivites.csv : permet de connaître la signification des états 1-5 de mainActivity_filtered.csv
* /generate1.0/ : Emplacement des scripts, fonctions et données générées
    * Dataprocess/ : Emplacement des fichiers générés
      * AR/ : Rythmes d'activités
        * Healthy/ : Vaches saines
          * filtered/ : Issus du fichier mainActivity_filtered.csv
          * all/ : Issus du fichier dataset1-1.csv
        * Unhealthy/ : Rythmes d'activités de vaches non saines
      * Models/ : Les modèles de Markov établis pour chaque vache
        * XXminutes/ : Pour des modèles basés sur des périodes de XX minutes
      * Simulation/ : Les simulations
        * XXminutes/ : Pour les simulations basés sur les modèles prenant les périodes de XX minutes
          * YYdays/ : Pour des simulations de YY jours
    * Fichiers .m : les fichiers fonctions/script pour générer les modèles, simuler, comparer,...

## Données

### dataset1-1.csv

Jeu de données issu de la ferme expérimentale Herbipôle d'INRAE (DOI : 10.15454, UE 1414, Marcenat, France). Chaque ligne de ce jeu de données a pour attributs :
- cow : le numéro de la vache
- date : la date de mesure
- hour : l'heure de mesure
- IN_ALLEYS : temps passé dans les allées mesuré en secondes
- REST : temps passé dans les logettes mesuré en secondes
- EAT : temps passé dans les auges mesuré en secondes
- ACTIVITY_LEVEL : mesure du rythme d'activité associé
- oestrus,calving,lameness,mastitis,LPS,acidosis,other_disease,accidents,disturbance,mixing,management_changes,OK : état de la vache au moment de la mesure. L'un de ces attributs vaut 1 et le reste vaut 0. Dans ce jeu de données, les injections d'acidose n'ont pas eu lieu, l'attribut "acidosis" vaut NA.

### mainActivity_filtered.csv

Jeu de données complémentaire à celui précédent, également issu de la ferme expérimentale. Les attributs sont :
- CowId : le numéro de la vache
- date : la date de mesure
- hour : l'heure et minute de la mesure (sous la forme HH:MM)
- mainActivity : l'activité exercée pendant la minute, allant de 1 à 5
  
La correspondance entre la numérotation et l'activité est :
- 1 : Immobile
- 2 : Marche
- 3 : Logette
- 4 : Mange
- 5 : Boit

Les couples CowId/date correspondent aux couples cow/date du jeu de données dataset1-1.csv de telle sorte à ce que ce ne soit ni des jours où la vache n'est pas dans l'état "OK", ni des jours flous (c'est-à-dire suffisamment proche d'un jour où la vache n'était pas dans l'état "OK").

## Fichiers script

### markov.m

Jeu de données utilisé : mainActivity_filtered.csv

L'exécution de ce script permet d'obtenir un modèle de simulation associé à chaque vache du jeu de de données en fonction de la taille des périodes souhaitée, réglable avec le paramètre *periodsize*.

Les modèles sont stockés dans Dataprocess/Models sous la forme de dossier regroupant les tailles de périodes, et dont les fichiers sont des fichiers .mat associés à une vache.

### simulation.m

Jeu de données utilisé : mainActivity_filtered.csv

L'exécution de ce script permet d'obtenir une simulation associé à chaque vache du jeu de de données en fonction de la taille des périodes souhaitée, sous réserve qu'un modèle correspondant ait déjà été créé.

Les paramètres de réglages de simulation sont :
- *periodsize* : taille des périodes souhaitées
- *nsd* : le nombre de jours que l'on souhaite simuler
  
Les résultats des simulations sont stockées dans Dataprocess/Simulation, puis en un dossier représentant la taille des périodes, puis dans un dossier représentant le nombre de jours simulés. Les fichiers sont des fichiers .mat associés à une vache.

### ar_compute.m

Jeu de données utilisé : mainActivity_filtered.csv

L'exécution de ce script permet de calculer les courbes de rythmes d'activités à partir du jeu de données mainActivity_filtered.csv, qui ne les renseigne pas directement. En théorie, les résultats obtenus sont assez proches avec les valeurs de rythme d'activités présentes dans le fichier dataset1-1.csv.

Les résultats sont stockés dans Dataprocess/AR/Healthy/filtered et les fichiers .mat sont associés à une vache.

### getar.m

Jeu de données utilisé : mainActivity_filtered.csv

L'exécution de ce script permet les courbes de rythmes d'activités dans des fichiers de façons à ce qu'on obtienne uniquement les courbes correspondant à des jours où les vaches sont saines, hors des jours floues, ou bien des courbes obtenus sur des vaches présentant des anomalies bien spécifiques.

Les résultats sont stockés dans :
- Dataprocess/AR/Healthy/all : les fichiers .mat correspondent à tous les rythmes d'activités d'une vache saine
- Dataprocess/AR/Unhealthy : les fichiers .mat correspondent à tous les rythmes d'activités des vaches dans un état spécifique 


### affichage.m

Ce script permet d'afficher divers résultats comparatifs sur les données réelles, les simulations, les rythmes d'activités. Il est possible de modifier le paramètre *periodsize* pour utiliser les modèles de simulation basés sur la taille de la période souhaitée, sous réserve que les modèles et simulations associés ont déjà été réalisé.
