--Charlie's Chocolate Factory company produces chocolates. The following product information is stored: product name, product ID, and quantity on hand. These chocolates are made up of many components. Each component can be supplied by one or more suppliers. The following component information is kept: component ID, name, description, quantity on hand, suppliers who supply them, when and how much they supplied, and products in which they are used. On the other hand following supplier information is stored: supplier ID, name, and activation status.


--Assumptions
--A supplier can exist without providing components.
--A component does not have to be associated with a supplier. It may already have been in the inventory.
--A component does not have to be associated with a product. Not all components are used in products.
--A product cannot exist without components. 

--Do the following exercises, using the data model.

     --a) Create a database named "Manufacturer"

     --b) Create the tables in the database.

     --c) Define table constraints.


CREATE DATABASE Manufacturer;
GO
USE Manufacturer;
GO

CREATE TABLE Product(
prod_id INT NOT NULL,
prod_name VARCHAR(50) NOT NULL,
quantity INT NOT NULL,
	CONSTRAINT PK_product PRIMARY KEY (prod_id)
);


CREATE TABLE Component (
comp_id INT NOT NULL,
comp_name VARCHAR(50) NOT NULL,
[description] VARCHAR(50) NOT NULL,
quantity_comp INT NOT NULL,
	CONSTRAINT PK_component PRIMARY KEY (comp_id)
);

CREATE TABLE Prod_Comp (
prod_id INT NOT NULL,
comp_id INT NOT NULL,
quantity_comp INT NOT NULL,
	CONSTRAINT PK_prod_comp PRIMARY KEY (prod_id, comp_id),
	CONSTRAINT FK_product_pc FOREIGN KEY(prod_id) REFERENCES [dbo].[Product](prod_id), 
	CONSTRAINT FK_component_pc FOREIGN KEY(comp_id) REFERENCES [dbo].[Component](comp_id)
);


CREATE TABLE Supplier (
supp_id INT NOT NULL,
supp_name VARCHAR(50) NOT NULL,
supp_location VARCHAR(50) NULL,
supp_country VARCHAR(50) NULL,
is_active BIT NOT NULL,
	CONSTRAINT PK_supplier PRIMARY KEY (supp_id)
);


CREATE TABLE Comp_Supp (
supp_id INT NOT NULL,
comp_id INT NOT NULL,
order_date DATE NOT NULL,
quantity INT NOT NULL,
	CONSTRAINT PK_comp_supp PRIMARY KEY (supp_id, comp_id),
	CONSTRAINT FK_supplier_ccs FOREIGN KEY(supp_id) REFERENCES [dbo].[Supplier](supp_id), 
	CONSTRAINT FK_component_cs FOREIGN KEY(comp_id) REFERENCES [dbo].[Component](comp_id)
);



--ALTERNATIVE SOLUTION 1
---------------------------------------
CREATE DATABASE Manufacturer;
GO
USE Manufacturer;
GO

CREATE TABLE Product(
prod_id INT IDENTITY (1, 1) PRIMARY KEY,
prod_name VARCHAR(50) NOT NULL,
quantity INT NOT NULL
);


CREATE TABLE Component (
comp_id INT IDENTITY (1, 1) PRIMARY KEY,
comp_name VARCHAR(50) NOT NULL,
[description] VARCHAR(50) NOT NULL,
quantity_comp INT NOT NULL	
);

CREATE TABLE Prod_Comp (
prod_id INT NOT NULL,
comp_id INT NOT NULL,
quantity_comp INT NOT NULL,
PRIMARY KEY (prod_id, comp_id),
FOREIGN KEY (prod_id) REFERENCES [dbo].[Product](prod_id) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (comp_id) REFERENCES [dbo].[Component](comp_id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Supplier (
supp_id INT IDENTITY (1, 1) PRIMARY KEY,
supp_name VARCHAR(50) NOT NULL,
supp_location VARCHAR(50) NULL,
supp_country VARCHAR(50) NULL,
is_active BIT NOT NULL	
);


CREATE TABLE Comp_Supp (
supp_id INT NOT NULL,
comp_id INT NOT NULL,
order_date DATE NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY (supp_id, comp_id),
FOREIGN KEY (supp_id) REFERENCES [dbo].[Supplier](supp_id) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (comp_id) REFERENCES [dbo].[Component](comp_id) ON DELETE CASCADE ON UPDATE CASCADE
);


--ALTERNATIVE SOLUTION 2
---------------------------------------

CREATE DATABASE Manufacturer;
GO
USE Manufacturer;
GO

CREATE TABLE Product(
prod_id INT NOT NULL,
prod_name VARCHAR(50) NOT NULL,
quantity INT NOT NULL	
);

ALTER TABLE [dbo].[Product]
ADD CONSTRAINT PK_product PRIMARY KEY (prod_id);




CREATE TABLE Component (
comp_id INT NOT NULL,
comp_name VARCHAR(50) NOT NULL,
[description] VARCHAR(50) NOT NULL,
quantity_comp INT NOT NULL	
);

ALTER TABLE [dbo].[Component]
ADD CONSTRAINT PK_component PRIMARY KEY (comp_id);



CREATE TABLE Prod_Comp (
prod_id INT NOT NULL,
comp_id INT NOT NULL,
quantity_comp INT NOT NULL	
);

ALTER TABLE [dbo].[Prod_Comp]
ADD CONSTRAINT PK_prod_comp PRIMARY KEY (prod_id, comp_id),
CONSTRAINT FK_product_pc FOREIGN KEY(prod_id) REFERENCES [dbo].[Product](prod_id), 
CONSTRAINT FK_component_pc FOREIGN KEY(comp_id) REFERENCES [dbo].[Component](comp_id);




CREATE TABLE Supplier (
supp_id INT NOT NULL,
supp_name VARCHAR(50) NOT NULL,
supp_location VARCHAR(50) NULL,
supp_country VARCHAR(50) NULL,
is_active BIT NOT NULL	
);

ALTER TABLE [dbo].[Supplier]
ADD CONSTRAINT PK_supplier PRIMARY KEY (supp_id);




CREATE TABLE Comp_Supp (
supp_id INT NOT NULL,
comp_id INT NOT NULL,
order_date DATE NOT NULL,
quantity INT NOT NULL	
);

ALTER TABLE [dbo].[Comp_Supp]
ADD CONSTRAINT PK_comp_supp PRIMARY KEY (supp_id, comp_id),
CONSTRAINT FK_supplier_ccs FOREIGN KEY(supp_id) REFERENCES [dbo].[Supplier](supp_id), 
CONSTRAINT FK_component_cs FOREIGN KEY(comp_id) REFERENCES [dbo].[Component](comp_id);