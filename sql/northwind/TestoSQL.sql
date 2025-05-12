/* 1.	Visualizzare i clienti (customers) in ordine alfabetico*/
SELECT *
FROM Customers
ORDER BY CompanyName;

/* 2.	Visualizzare i clienti che non hanno il fax*/
SELECT *
FROM Customers
WHERE Fax IS NULL;

/* 3.	Selezionare i nomi dei clienti (CompanyName) che iniziano con le lettere P, Q, R, S*/
SELECT CompanyName
FROM Customers
WHERE CompanyName LIKE 'P%'
    OR CompanyName LIKE 'Q%'
    OR CompanyName LIKE 'R%'
    or CompanyName LIKE 'S%';

/* 4.	Visualizzare Nome e Cognome degli impiegati assunti (HireDate) dopo il '1993-05-03' e aventi titolo di “Sales Representative”*/
SELECT FirstName,
    LastName
FROM Employees
WHERE HireDate >= DATE('1993-05-03')
    AND Title = 'Sales Representative';

/* 5.	Selezionare la lista dei prodotti non sospesi (attributo discontinued), visualizzando 
 anche il nome della categoria di appartenenza*/
SELECT p.ProductID,
    p.ProductName,
    c.CategoryName
FROM Products AS p
    JOIN Categories AS c ON p.CategoryID = c.CategoryID
WHERE Discontinued = 0;

/* 6. Selezionare gli ordini relativi al cliente ‘Ernst Handel’ (CompanyName)*/
SELECT o.*
FROM Orders AS o
    JOIN Customers AS c ON o.CustomerID = c.CustomerID
WHERE c.CompanyName = 'Ernst Handel';

/* 7.	Selezionare il nome della società e il telefono dei corrieri (shippers) che hanno consegnato 
 ordini nella città di ‘Rio sde Janeiro’ (ShipCity in orders)
 N.B. nella tabella orders l'id corriere è l'attributo ShipVia*/
SELECT s.CompanyName,
    s.Phone
FROM Shippers AS s
    JOIN Orders AS o ON s.ShipperID = o.ShipVia
WHERE o.ShipCity = 'Rio de Janeiro';

/* 8.	Selezionare gli ordini (OrderID, OrderDate, ShippedDate) per cui la spedizione (ShippedDate)
 è avvenuta entro 30 giorni dalla data dell’ordine (OrderDate)*/
SELECT OrderID,
    OrderDate,
    ShippedDate
FROM Orders
WHERE DATEDIFF(ShippedDate, OrderDate) <= 30;

/* 9.	Selezionare l’elenco dei prodotti che hanno un costo compreso tra 18 e 50, ordinando il risultato
 in ordine di prezzo crescente */
SELECT *
FROM Products
WHERE UnitPrice BETWEEN 18 AND 50
ORDER BY UnitPrice ASC;

/* 10.	Selezionare tutti i clienti (CustomerID, CompanyName) che hanno ordinato il prodotto 'Chang'*/
SELECT DISTINCT c.CustomerID,
    c.CompanyName
FROM Customers AS c
    JOIN Orders as o ON c.CustomerID = o.CustomerID
    JOIN `Order Details` AS od ON o.OrderID = od.OrderID
    JOIN Products AS p ON p.ProductID = od.ProductID
WHERE p.ProductName = 'Chang';

/* 11.	Selezionare i clienti che non hanno mai ordinato prodotti di categoria ‘Beverages’*/
SELECT *
FROM Customers
WHERE CustomerID NOT IN (
        SELECT c.CustomerID
        FROM Customers AS c
            JOIN Orders as o ON c.CustomerID = o.CustomerID
            JOIN `Order Details` AS od ON o.OrderID = od.OrderID
            JOIN Products AS p ON p.ProductID = od.ProductID
            JOIN Categories AS ca ON ca.CategoryID = p.CategoryID
        WHERE ca.CategoryName = 'Beverages'
    );

/* 12.	Selezionare il prodotto più costoso*/
SELECT ProductID
FROM Products
WHERE UnitPrice = (
        SELECT MAX(UnitPrice)
        FROM Products
    );

/* 13.	Visualizzare l’importo totale di ciascun ordine fatto dal cliente 'Ernst Handel' (CompanyName)*/
SELECT o.OrderID,
    SUM(od.UnitPrice * Quantity * (1 - od.Discount)) AS Subtotal
FROM Orders AS o
    JOIN `Order Details` AS od ON od.OrderID = o.OrderID
    JOIN Customers AS c ON c.CustomerID = o.CustomerID
WHERE c.CompanyName = 'Ernst Handel'
GROUP BY o.OrderID;

/* 14.	Selezionare il numero di ordini ricevuti in ciascun anno */
SELECT YEAR(OrderDate) as `Year`,
    COUNT(*) as NORders
FROM Orders
GROUP BY `Year`;

/* 15.	Visualizzare per ogni impiegato (EmployeeID, LastName, FirstName) il numero di clienti distinti serviti per ciascun paese (Country),
 visualizzando il risultato in ordine di impiegato e di paese*/
SELECT e.EmployeeID,
    e.LastName,
    e.FirstName,
    c.Country,
    COUNT(DISTINCT o.CustomerID) as NCustomers
FROM Employees AS e
    JOIN Orders AS o ON e.EmployeeID = o.EmployeeID
    JOIN Customers AS c ON c.CustomerID = o.CustomerID
GROUP BY e.EmployeeID,
    e.LastName,
    e.FirstName,
    c.Country
ORDER BY NCustomers,
    c.Country;

/* 16.	Visualizzare per ogni corriere il numero di consegne effettuate, compresi i dati dei 
 corrieri che non hanno effettuato nessuna consegna */
SELECT s.ShipperID,
    s.CompanyName,
    COUNT(o.OrderID)
FROM Shippers AS s
    LEFT JOIN Orders AS o ON s.ShipperID = o.ShipVia
GROUP BY s.ShipperID,
    s.CompanyName;

/* 17.	Visualizzare i fornitori (SupplierID, CompanyName) che forniscono un solo prodotto */
SELECT s.SupplierID,
    s.CompanyName
FROM Suppliers AS s
    JOIN Products AS p ON s.SupplierID = p.SupplierID
GROUP BY s.SupplierID
HAVING COUNT(p.ProductID) = 1;

/* 18.	Visualizzare tutti gli impiegati che sono stati assunti dopo Margaret Peacock */
SELECT *
FROM Employees
WHERE HireDate > (
        SELECT HireDate
        FROM Employees
        WHERE FirstName = 'Margaret'
            AND LastName = 'Peacock'
    );

/* 19.	Visualizzare gli ordini relativi al prodotto più costoso */
WITH MostExpensiveProduct(ProductID) AS (
    SELECT ProductID
    FROM Products
    WHERE UnitPrice = (
            SELECT MAX(UnitPrice)
            FROM Products
        )
)
SELECT DISTINCT o.*
FROM Orders AS o
    JOIN `Order Details` AS od ON o.OrderID = od.OrderID
WHERE od.ProductID IN (
        SELECT *
        FROM MostExpensiveProduct
    );

/* 20.	Visualizzare i nomi dei clienti per i quali l’ultimo ordine è relativo al 1998  */
WITH LastOrder(CustomerID, OrderID, OrderDate) AS (
    SELECT o.CustomerID,
        o.OrderID,
        o.OrderDate
    FROM Orders AS o
    WHERE o.OrderDate >= ALL (
            SELECT OrderDate
            FROM Orders
            WHERE CustomerID = o.CustomerID
        )
)
SELECT DISTINCT c.*
FROM LastOrder AS lo
    JOIN Customers AS c ON c.CustomerID = lo.CustomerID
WHERE YEAR(OrderDate) = 1998;


/* 21.	Contare il numero di clienti che non hanno effettuato ordini */
SELECT COUNT(*)
FROM (
        SELECT CustomerID
        FROM Customers
        EXCEPT
        SELECT DISTINCT CustomerID
        FROM Orders
    ) as NoOrdersCustomers;

/* 22.	Visualizzare il prezzo minimo, massimo e medio dei prodotti per ciascuna categoria */
SELECT CategoryID,
    MIN(UnitPrice),
    MAX(UnitPrice),
    AVG(UnitPrice)
FROM Products
GROUP BY CategoryID;

/* 23.	Selezionare i prodotti che hanno un prezzo superiore al prezzo medio dei prodotti forniti dallo stesso fornitore */
SELECT p.*
FROM Products AS p
WHERE UnitPrice > (
        SELECT AVG(UnitPrice)
        FROM Products
        WHERE SupplierID = p.SupplierID
    );

/* 24.	Visualizzare, in ordine decrescente rispetto alla quantità totale venduta, i prodotti che hanno venduto una quantità 
 totale superiore al prodotto ‘Chai’ */
WITH QuantitySold(ProductID, Quantity) AS (
    SELECT ProductID,
        SUM(Quantity)
    FROM `Order Details`
    GROUP BY ProductID
)
SELECT p.*
FROM QuantitySold AS qs
    JOIN Products AS p ON qs.ProductID = p.ProductID
WHERE Quantity > (
        SELECT qs.Quantity
        FROM QuantitySold AS qs
            JOIN Products AS p ON qs.ProductID = p.ProductID
        WHERE p.ProductName = 'Chai'
    )
ORDER BY Quantity DESC;

/* 25.	Visualizzare il nome dei clienti che hanno fatto almeno due ordini di importo superiore a 15000 */
WITH OrderTotal(OrderID, Total) AS (
    SELECT OrderID,
        SUM(UnitPrice * Quantity * (1 - Discount))
    FROM `Order Details`
    GROUP BY OrderID
)
SELECT DISTINCT c.CompanyName
FROM OrderTotal AS ot
    JOIN Orders AS o ON o.OrderID = ot.OrderID
    JOIN Customers AS c ON c.CustomerID = o.CustomerID
WHERE ot.Total > 15000
GROUP BY c.CompanyName
HAVING COUNT(*) >= 2;


/* 26.	Individuare i codici dei clienti che hanno fatto un numero di ordini pari a quello del cliente 'Eastern Connection' */
SELECT o.CustomerID
FROM Orders AS o
    JOIN Customers AS c ON c.CustomerID = o.CustomerID
WHERE c.CompanyName != 'Eastern Connection'
GROUP BY o.CustomerID
HAVING COUNT(*) = (
        SELECT COUNT(*)
        FROM Orders AS o
            JOIN Customers AS c ON c.CustomerID = o.CustomerID
        WHERE c.CompanyName = 'Eastern Connection'
    );

/* 27. Visualizzare il numero di ordini ricevuti nel 1997 e di importo superiore a 10000*/
WITH OrderTotal(OrderID, Total) AS (
    SELECT OrderID,
        SUM(UnitPrice * Quantity * (1 - Discount))
    FROM `Order Details`
    GROUP BY OrderID
)
SELECT o.*
FROM OrderTotal AS ot
    JOIN Orders AS o ON o.OrderID = ot.OrderID
WHERE ot.Total > 10000
    AND YEAR(o.OrderDate) = 1997;

/* 28. Visualizzare i corrieri che hanno consegnato un numero di ordini superiore al numero di ordini consegnati da Speedy Express. */
WITH ShippersDeliveries(ShipperID, NDeliveries) AS (
    SELECT s.ShipperID,
        COUNT(o.OrderID)
    FROM Shippers AS s
        LEFT JOIN Orders AS o ON s.ShipperID = o.ShipVia
    GROUP BY s.ShipperID
)
SELECT s.*
FROM Shippers AS s
    JOIN ShippersDeliveries AS sd ON s.ShipperID = sd.ShipperID
WHERE sd.NDeliveries > (
        SELECT sd.NDeliveries
        FROM Shippers AS s
            JOIN ShippersDeliveries AS sd ON s.ShipperID = sd.ShipperID
        WHERE s.CompanyName = 'Speedy Express'
    );

/* 29. Visualizzare i clienti che hanno ordinato prodotti di tutte le categorie */
WITH CustomersCategories(CustomerID, NCategories) AS (
    SELECT DISTINCT o.CustomerID,
        COUNT(DISTINCT p.CategoryID)
    FROM Orders AS o
        JOIN `Order Details` AS od ON o.OrderID = od.OrderID
        JOIN Products AS p ON p.ProductID = od.ProductID
    GROUP BY o.CustomerID
)
SELECT c.*
FROM CustomersCategories AS cc
    JOIN Customers AS c ON c.CustomerID = cc.CustomerID
WHERE cc.NCategories = (
        SELECT COUNT(*)
        FROM Categories
    );