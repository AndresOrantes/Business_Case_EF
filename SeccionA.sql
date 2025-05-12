/*A1) Cada año se ofrece un reconocimiento a los clientes que compran más de 500 productos. 
En esta ocasión, buscamos identificar cuáles son los clientes que han recibido más 
reconocimientos en toda la historia. 

	-Elabora un query que despliegue solamente los 4 clientes más reconocidos. */

SELECT CustomerID AS ID_Cliente, CustomerName AS Nombre_Cliente, ContactName AS Nombre_Contacto, count(*) AS Num_Reconocimientos
FROM( #Subquery para clientes con más de 500 productos
	SELECT c.CustomerID, c.CustomerName, c.ContactName, YEAR(OrderDate) AS order_year
    FROM Customers c
    JOIN Orders o ON c.CustomerID=o.CustomerID
    JOIN OrderDetails od ON o.OrderID=od.OrderID 
    GROUP BY c.CustomerID, c.CustomerName, c.ContactName, order_year
    HAVING SUM(od.Quantity) >500 
) AS Reconocimientos
GROUP BY ID_Cliente, Nombre_Cliente, Nombre_Contacto
ORDER BY Num_Reconocimientos DESC
LIMIT 4;


/*A2) Debido a una negociación con el gobierno mexicano, nos ofrecieron un incentivo para 
exentar ciertos impuestos de algunos artículos. Este incentivo aplica para las ventas 
entregadas en México que fueron realizadas en Agosto de 1996. Las algas marinas y los 
pescados tienen un 16% de incentivo, mientras que las bebidas solo tienen un 5% de incentivo. 
 
	-Elabora un query que despliegue tanto el total del incentivo, como el detalle de cada categoría de productos.*/


SELECT cat.CategoryID, cat.CategoryName, 
SUM(p.Price * od.Quantity *
    CASE
        WHEN p.CategoryID=1 THEN 0.05 # Beverages, esto aparece en categoryName
        WHEN p.CategoryID=8 THEN 0.16 # Seaweed and fish, esto aparece en Description
        ELSE 0
    END) AS Incetivo_total
FROM Categories cat
JOIN Products p ON cat.CategoryID=p.CategoryID
JOIN OrderDetails od ON p.ProductID=od.ProductID
JOIN Orders o ON od.OrderID=o.OrderID
JOIN Customers c ON o.CustomerID=c.CustomerID
WHERE c.Country="Mexico" 
AND o.OrderDate BETWEEN "1996-08-01" AND "1996-08-31"
GROUP BY cat.CategoryID, cat.CategoryName;



/*A3) Con el cambio en un sistema de ventas, algunos colaboradores tuvieron problemas y no vendieron como antes. 
Queremos identificar si los empleados que se encontraban dentro de los tres primeros lugares de venta ($) al finalizar
el primer semestre de 1997 terminaron dentro de los últimos 3 lugares de venta en el segundo semestre de 1997.  

- Elabora un query que muestre los tres empleados con más venta en el primer 
semestre del 97 y una columna que muestre “Sí” en caso que se encontraran en los 
últimos 3 lugares de venta del segundo semestre y “No” en caso contrario. */

SELECT h.EmployeeID, h.EmployeeName, CASE WHEN  l.EmployeeID IS NOT NULL THEN "Sí" ELSE "No" END AS UltimosLugares
FROM( #Subquery para tener los tres primeros lugares en el primer semestre
SELECT e.EmployeeID, CONCAT(e.FirstName, " ", e.LastName) AS EmployeeName, 
SUM(p.Price * od.Quantity) AS Ventas_Totales
FROM Employees e
JOIN Orders o ON e.EmployeeID=o.EmployeeID
JOIN OrderDetails od ON o.OrderID=od.OrderID
JOIN Products p ON od.ProductID=p.ProductID
WHERE o.OrderDate BETWEEN "1997-01-01" AND "1997-06-30" 
GROUP BY e.EmployeeID, EmployeeName
ORDER BY Ventas_Totales DESC
LIMIT 3
) AS h #highest
LEFT JOIN ( #Subquery para tener los tres últimos lugares en el segundo semestre
SELECT e.EmployeeID, CONCAT(e.FirstName, " ", e.LastName) AS EmployeeName, 
SUM(p.Price * od.Quantity) AS Ventas_Totales
FROM Employees e
JOIN Orders o ON e.EmployeeID=o.EmployeeID
JOIN OrderDetails od ON o.OrderID=od.OrderID
JOIN Products p ON od.ProductID=p.ProductID
WHERE o.OrderDate BETWEEN "1997-07-01" AND "1997-12-31" 
GROUP BY e.EmployeeID, EmployeeName
ORDER BY Ventas_Totales ASC
LIMIT 3
) AS l #lowest
ON h.employeeID=l.employeeID;
