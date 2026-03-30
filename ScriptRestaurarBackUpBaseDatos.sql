/* ============================================================
   MANUAL DE RESTAURACIÓN DE BACKUPS EN SQL SERVER
   Caso práctico: Restaurar FULL + Diferencial
   ============================================================ */

/* 🔎 VALIDACIONES INICIALES
   Antes de restaurar, asegúrate de que las carpetas de Backup y DATA existen
   y que el servicio de SQL Server tiene permisos de lectura/escritura.
   Si el archivo está en una unidad de red o carpeta sin permisos, fallará.
*/

/* Ver el contenido del backup: tipo de respaldo (FULL, DIFERENCIAL, LOG) */
RESTORE HEADERONLY
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\NorthwindBackUp.bak';

/* Ver los nombres lógicos de los archivos dentro del FULL (para usar en WITH MOVE) */
RESTORE FILELISTONLY
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\NorthwindBackUp.bak';

/* Ver los nombres lógicos de los archivos dentro del diferencial (para confirmar consistencia) */
RESTORE FILELISTONLY
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\NorthwindBackUpDiferencial.bak';


/* ============================================================
   RESTAURACIÓN DEL FULL BACKUP
   Se restaura el FULL con NORECOVERY para dejar la base en estado RESTORING
   y permitir aplicar el diferencial después.
   ============================================================ */
USE master;
RESTORE DATABASE NorthwindXXI
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\NorthwindBackUp.bak'
WITH MOVE 'Northwind' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\northwnd.mdf',
     MOVE 'Northwind_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\northwnd.ldf',
     NORECOVERY;


/* ============================================================
   RESTAURACIÓN DEL DIFERENCIAL
   Se aplica el diferencial con RECOVERY para finalizar la cadena
   y dejar la base lista para usarse.
   ============================================================ */
USE master;
RESTORE DATABASE NorthwindXXI
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\NorthwindBackUpDiferencial.bak'
WITH RECOVERY;


/* ============================================================
   VALIDACIONES FINALES
   Confirmar que la base está en línea, sin corrupción y con el
   nivel de compatibilidad correcto.
   ============================================================ */

/* Verificar que la base está ONLINE */
SELECT name, state_desc 
FROM sys.databases 
WHERE name = 'NorthwindXXI';

/* Chequeo de integridad de la base restaurada */
DBCC CHECKDB('NorthwindXXI');

/* Ajustar compatibilidad según la versión de SQL Server (ejemplo: 150 = SQL Server 2019) */
ALTER DATABASE NorthwindXXI 
SET COMPATIBILITY_LEVEL = 150;