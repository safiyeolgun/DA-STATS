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
supp_location VARCHAR(50) NOT NULL,
supp_country VARCHAR(50) NOT NULL,
is_active bit NOT NULL,
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


