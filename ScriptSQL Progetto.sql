CREATE DATABASE Università;
USE Università;

CREATE TABLE Studente(
Matricola int not null,
Nome varchar(20) not null,
Cognome varchar(20) not null,
Cf varchar(20) not null,
tipoStudente varchar(20) not null,
anniFuoricorso int ,
primary key(Matricola)
);

CREATE TABLE Docente(
Id int not null,
Nome varchar(20) not null,
Cognome varchar(20) not null,
Cf varchar(20) not null,
Citta varchar(20) not null,
Via varchar(20) not null,
Cap int not null,
Stipendio float not null,
primary key(Id)
);

CREATE TABLE Corso(
nomeDelCorso varchar(20) not null,
Anno int not null,
idDocente int not null,
Ore int not null,
oreTotali int not null,
primary key(nomeDelCorso,Anno),
foreign key(idDocente) REFERENCES Docente(Id)
);

CREATE TABLE Esame(
idEsame int not null,
nomeDelCorso varchar(20) not null,
annoCorso int not null,
numeroCfu int not null,
votoConseguito int not null,
primary key(idEsame,nomeDelCorso,annoCorso),
foreign key(nomeDelCorso,annoCorso) REFERENCES Corso(nomeDelCorso,Anno)
);

CREATE TABLE Appello(
codiceAppello int not null,
idEsame int not null,
nomeEsame varchar(20) not null,
annoEsame int not null,
dataAppello date not null,
numeroMassimoIscrizioni int not null,
primary key(codiceAppello),
foreign key(idEsame,nomeEsame,annoEsame) REFERENCES Esame(idEsame,nomeDelCorso,annoCorso)
);

CREATE TABLE Iscrizione(
dataIscrizione date not null,
matricolaStudente int not null,
codiceAppello int not null,
primary key(dataIscrizione),
foreign key(matricolaStudente) REFERENCES Studente(Matricola),
foreign key(codiceAppello) REFERENCES Appello(codiceAppello)
);

CREATE TABLE TitoloDiStudio(
Docente int not null,
nomeTitolo varchar(20) not null,
primary key(Docente),
foreign key(Docente) REFERENCES Docente(Id)
);

INSERT INTO Studente (Matricola,Nome,Cognome,Cf,tipoStudente,anniFuoricorso)
VALUES
(1, 'Mario', 'Rossi', 'RSSMRA01M01H501Z', 'Regolare',0),
(2, 'Luca', 'Verdi', 'VRDLCA02M02H502Y', 'Fuori Corso', 2),
(3, 'Anna', 'Bianchi', 'BNCHAN03M03H503X', 'Regolare', 0);

INSERT INTO Docente(Id,Nome,Cognome,Cf,Citta,Via,Cap,Stipendio) 
VALUES
(201, 'Giuseppe', 'Conte', 'CNTGPP01M01H501A', 'Roma', 'Via Roma 123', 00100,1800),
(202, 'Maria', 'Russo', 'RSSMRA02M02H502B', 'Milano', 'Via Milano 456', 20100,2000),
(203, 'Luigi', 'Ferrari', 'FRRLGI03M03H503C', 'Napoli', 'Via Napoli 789', 80100,4000.50);

INSERT INTO Corso(nomeDelCorso,Anno,idDocente,Ore,oreTotali) 
VALUES
('Matematica', 2024 , 201, 40, 120),
('Fisica', 2024, 202, 30, 90),
('Chimica',2024, 203, 50, 150);

INSERT INTO Esame(idEsame,nomeDelCorso,annoCorso,numeroCfu,votoConseguito) 
VALUES
(10,'Matematica', 2024 , 10, 28),
(11,'Fisica', 2024 , 8 , 30),
(12,'Chimica', 2024 , 7 , 22);

INSERT INTO Appello(codiceAppello,idEsame,nomeEsame,annoEsame,dataAppello,numeroMassimoIscrizioni) 
VALUES
(101,10, 'Matematica', 2024 , '2024-03-01', 50),
(102,11, 'Fisica', 2024 ,'2024-03-02', 40),
(103,12, 'Chimica', 2024 ,'2024-03-03', 30);

INSERT INTO Iscrizione(dataIscrizione,matricolaStudente,codiceAppello)
VALUES
('2024-02-23', 1, 101),
('2024-02-24', 2, 102),
('2024-02-25', 3, 103);

INSERT INTO TitoloDiStudio (Docente,nomeTitolo)
VALUES
(201, 'Laurea in Matematica'),
(202, 'Laurea in Fisica '),
(203, 'Laurea in Chimica ');

Select*
FROM Studente S
WHERE (S.tipoStudente = 'Fuori Corso' and S.anniFuoricorso < 2) or ( S.tipoStudente = 'Regolare')
order by S.Cognome;

Select S.Matricola, S.Nome,S.Cognome,A.nomeEsame,A.dataAppello
FROM Studente S JOIN Iscrizione I
on S.Matricola = I.matricolaStudente
JOIN Appello A
on I.codiceAppello = A.codiceAppello
WHERE S.tipoStudente = 'Regolare';

Select sum(D.Stipendio) as SommaStipendi
FROM Docente D;

Select C.Anno as AnnoDelCorso, sum(D.Stipendio) as SommaStipendi
FROM Docente D JOIN Corso C
on D.Id = C.idDocente
group by C.Anno;

Select C.Anno as AnnoDelCorso, sum(D.Stipendio) as SommaStipendi
FROM Docente D JOIN Corso C
on D.Id = C.idDocente
group by C.Anno
HAVING SommaStipendi > 5000;

CREATE VIEW ContaStipendi as
(
Select C.Anno as AnnoDelCorso, sum(D.Stipendio) as SommaStipendi
FROM Docente D JOIN Corso C
on D.Id = C.idDocente
group by C.Anno
);
Select *
FROM ContaStipendi
WHERE SommaStipendi = (
Select max(SommaStipendi)
FROM ContaStipendi
);

CREATE VIEW ContaCfu as
(
Select D.Nome as NomeDocente, sum(E.numeroCfu) as SommaCfu
FROM Docente D JOIN Corso C
on D.Id = C.idDocente
JOIN Esame E
on E.nomeDelCorso = C.nomeDelCorso
group by D.Nome
);
Select *
FROM ContaCfu
WHERE SommaCfu = (
Select max(SommaCfu)
FROM ContaCfu
);

SELECT e.nomeDelCorso
FROM Esame e 
UNION
SELECT c.nomeDelCorso
FROM Corso c;

SELECT *
FROM Studente s
WHERE NOT EXISTS (
   SELECT a.nomeEsame
   FROM Appello a 
   WHERE a.nomeEsame = 'Matematica'
   AND NOT EXISTS (
      SELECT i.codiceAppello
      FROM Iscrizione i
      WHERE i.matricolaStudente = s.Matricola
         AND i.codiceAppello = a.codiceAppello
   )
);