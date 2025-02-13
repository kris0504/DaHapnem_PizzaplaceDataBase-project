USE [master]
GO
/****** Object:  Database [DaHapnemDB]    Script Date: 1/29/2024 11:33:25 AM ******/
CREATE DATABASE [DaHapnemDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DaHapnemDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\DaHapnemDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'DaHapnemDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\DaHapnemDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [DaHapnemDB] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DaHapnemDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [DaHapnemDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DaHapnemDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DaHapnemDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DaHapnemDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DaHapnemDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [DaHapnemDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [DaHapnemDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DaHapnemDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DaHapnemDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DaHapnemDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DaHapnemDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DaHapnemDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DaHapnemDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DaHapnemDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DaHapnemDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [DaHapnemDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DaHapnemDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DaHapnemDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [DaHapnemDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [DaHapnemDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DaHapnemDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [DaHapnemDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [DaHapnemDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [DaHapnemDB] SET  MULTI_USER 
GO
ALTER DATABASE [DaHapnemDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [DaHapnemDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [DaHapnemDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [DaHapnemDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [DaHapnemDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [DaHapnemDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [DaHapnemDB] SET QUERY_STORE = OFF
GO
USE [DaHapnemDB]
GO
/****** Object:  UserDefinedFunction [dbo].[udf_PizzaPercentSold2]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_PizzaPercentSold2]()
RETURNS @PizzaPecrentSold TABLE
(
	[Name] nvarchar(32),
	[Size] nvarchar(32),
	[Count] decimal,
	[Percentige] nvarchar(32)
)
AS
BEGIN
DECLARE @SumOfAllPizza decimal = (SELECT SUM(Quantity) FROM OrderPizza)
INSERT INTO @PizzaPecrentSold 
	(
		[Name],
		[Size],
		[Count],
		[Percentige]
	)
	SELECT 
		PN.Name,
		P.Size,
		SUM(OP.Quantity) as [Count],
		FORMAT((SUM(OP.Quantity)+0.0)/@SumOfAllPizza,'0.00 %') as [Percentige]
	FROM
		Pizza as P 
		inner join PizzaName as PN 
		on P.PizzaNameId = PN.PizzaNameId
		inner join OrderPizza as OP
		on P.PizzaId = OP.PizzaId
	GROUP BY 
		PN.Name,P.Size
RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_PriceByDateAndName]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   function [dbo].[udf_PriceByDateAndName](@OrderDate Date,@ClientName nvarchar(30))
returns money
as 
begin
 declare @orderPrice money;

 select @orderPrice= sum(price*Quantity) from Pizza as p
 join OrderPizza as op on p.PizzaId=op.PizzaId
 join [Order] as o on o.OrderId=op.OrderId
 join Clients as c on c.ClientId=o.ClientId
 where c.Name=@ClientName
 and o.Date=@OrderDate

 return @orderPrice;
 end
GO
/****** Object:  Table [dbo].[OrderPizza]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderPizza](
	[OrderId] [int] NOT NULL,
	[PizzaId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK_OrderPizza_1] PRIMARY KEY CLUSTERED 
(
	[OrderId] ASC,
	[PizzaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Order]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Order](
	[OrderId] [int] IDENTITY(1,1) NOT NULL,
	[CourierId] [int] NOT NULL,
	[ClientId] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Hour] [time](7) NOT NULL,
 CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
(
	[OrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Courier]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Courier](
	[CourierId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](32) NOT NULL,
	[UCN] [nvarchar](10) NOT NULL,
	[Phone] [nvarchar](12) NOT NULL,
 CONSTRAINT [PK_Courier] PRIMARY KEY CLUSTERED 
(
	[CourierId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pizza]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pizza](
	[PizzaId] [int] IDENTITY(1,1) NOT NULL,
	[PizzaNameId] [int] NOT NULL,
	[Size] [nvarchar](32) NOT NULL,
	[Price] [money] NOT NULL,
 CONSTRAINT [PK_Pizza] PRIMARY KEY CLUSTERED 
(
	[PizzaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Clients]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clients](
	[ClientId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](30) NOT NULL,
	[Address] [nvarchar](100) NOT NULL,
	[Phone] [nvarchar](12) NOT NULL,
 CONSTRAINT [PK_Clients] PRIMARY KEY CLUSTERED 
(
	[ClientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PizzaName]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PizzaName](
	[PizzaNameId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_PizzaName] PRIMARY KEY CLUSTERED 
(
	[PizzaNameId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[udf_FindPizzaByPhone]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   Function [dbo].[udf_FindPizzaByPhone]
	(@ClientPhone nvarchar(12),@OrderDate Date,@CourierPhone nvarchar(12))
Returns Table
AS
Return
(
	Select PN.Name, OP.Quantity
	From 
	Pizza As P inner join PizzaName as PN on P.PizzaNameId = PN.PizzaNameId 
	inner join OrderPizza as OP on OP.PizzaId = P.PizzaId
	inner join [Order] as O on OP.OrderId = O.OrderId
	inner join Clients as Cl on Cl.ClientId = O.ClientId
	inner join Courier as Co on Co.CourierId = O.CourierId
	Where Cl.Phone = @ClientPhone AND O.Date = @OrderDate AND Co.Phone = @CourierPhone
)
GO
/****** Object:  Table [dbo].[Ingredients]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ingredients](
	[IngredientId] [int] NOT NULL,
	[PizzaNameId] [int] NOT NULL,
 CONSTRAINT [PK_Ingredients] PRIMARY KEY CLUSTERED 
(
	[IngredientId] ASC,
	[PizzaNameId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IngredientsNames]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IngredientsNames](
	[IngredientId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_IngredientsNames] PRIMARY KEY CLUSTERED 
(
	[IngredientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[udf_FindPizzaWithLowerPrice]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   function [dbo].[udf_FindPizzaWithLowerPrice]
(@Price INT)
RETURNS Table
AS
RETURN
(
	SELECT 
		DISTINCT PN.Name,
		P.Size,
		P.Price,
		STUFF(
			(
			SELECT 
				', ' + INs.Name
			FROM 
				PizzaName as PN 
				inner join Ingredients as I on I.PizzaNameId = PN.PizzaNameId
				inner join IngredientsNames as INs on INs.IngredientId = I.IngredientId
			WHERE
				P.PizzaNameId = PN.PizzaNameId
			FOR xml path('')
			),1,1,''
		) as [Ingredients]
	FROM 
		Pizza as P
		inner join PizzaName as PN on P.PizzaNameId = PN.PizzaNameId 
		inner join Ingredients as I on I.PizzaNameId = PN.PizzaNameId
		inner join IngredientsNames as INs on INs.IngredientId = I.IngredientId
	WHERE
		@Price > P.Price
)
GO
/****** Object:  UserDefinedFunction [dbo].[udf_PizzaByDescOrPart]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   function [dbo].[udf_PizzaByDescOrPart](@DescriptionSearch nvarchar(max))
returns table
as return
(
select pn.Name, STRING_AGG(ing.Name,' ') as 'Description' from PizzaName as pn
inner join Ingredients as i on i.PizzaNameId=pn.PizzaNameId
inner join IngredientsNames as ing on ing.IngredientId=i.IngredientId
group by pn.Name
having STRING_AGG(ing.Name,' ') like '%'+@DescriptionSearch+'%'
)
GO
/****** Object:  UserDefinedFunction [dbo].[udf_PriceSumBySize]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_PriceSumBySize]()
RETURNS TABLE
AS
RETURN
(
	SELECT
		P.Size as [Size],SUM(P.Price*OP.Quantity) as [Sum Price]
	FROM 
		OrderPizza as OP inner join Pizza as P on P.PizzaId = OP.PizzaId
	GROUP BY P.Size
)
GO
/****** Object:  UserDefinedFunction [dbo].[udf_BestSellerByDate]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_BestSellerByDate](@StartDate DATE, @EndDate DATE)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP 1
		PN.Name, SUM(OP.Quantity) as [Count]
	FROM
		[Order] as O inner join OrderPizza as OP on O.OrderId = OP.OrderID
		inner join Pizza as P on OP.PizzaId = P.PizzaId
		inner join PizzaName as PN on P.PizzaNameId = PN.PizzaNameId
	GROUP BY
		PN.Name,O.Date
	HAVING
		O.Date Between @StartDate AND @EndDate
	ORDER BY
		SUM(OP.Quantity) desc
)
GO
/****** Object:  UserDefinedFunction [dbo].[udf_OrderSumAndCountByPhone]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   function [dbo].[udf_OrderSumAndCountByPhone](@ClientPhoneNumber nvarchar(12))
returns table
as return
(
select COUNT(o.OrderId) as 'count', SUm(p.Price*op.Quantity) as 'sum' from Clients as c
join [Order] as o on o.ClientId=c.ClientId
join OrderPizza as op on op.OrderId=o.OrderId
join Pizza as p on p.PizzaId=op.PizzaId
where c.Phone like '%'+@ClientPhoneNumber+'%'
group by o.OrderId
)
GO
/****** Object:  UserDefinedFunction [dbo].[udf_PizzaPercentSold]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_PizzaPercentSold]()
RETURNS TABLE
AS
RETURN
(
	SELECT PN.Name,P.Size,SUM(OP.Quantity) as [Count],(SUM(OP.Quantity)+0.0)/(SELECT SUM(Quantity) FROM OrderPizza)*100 as [Percentige]
	FROM
		Pizza as P 
		inner join PizzaName as PN 
		on P.PizzaNameId = PN.PizzaNameId
		inner join OrderPizza as OP
		on P.PizzaId = OP.PizzaId
	GROUP BY 
		PN.Name,P.Size
)
GO
/****** Object:  UserDefinedFunction [dbo].[udf_CourierSum]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   function [dbo].[udf_CourierSum]()
returns table
as
return
(
	select Name,
		COUNT([OrderId])*0.75*4 as 'SumCourier' 
	from Courier as c
	join [Order] as o
	on c.CourierId=o.CourierId
	group by 
		Name
)
GO
SET IDENTITY_INSERT [dbo].[Clients] ON 

INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (1, N'Юсуф Халил', N'ул. Петър Райчев № 35, стая 1212', N'01020304567')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (2, N'Лили Панайотова', N'ул. Васил Априлов № 22, ет. 2, ап. 3', N'0894131313')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (3, N'Дора Врачанска', N'ул. Синигер № 3 Б', N'052880099')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (4, N'Николаос Пломарис', N'ул. Чаталджа № 19, ет. 4, ап, 7', N'0898202020')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (5, N'Калин Плевнелиев', N'ул. Пирин № 22, вход В, ет. 6, ап. 21', N'0870001002')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (6, N'Панайот Иванов', N'кв. Младост, блок 213, вх. А, ап. 31', N'0778899001')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (7, N'Орлин Димитров', N'бул. Владислав № 124, ет. 6, ап. 15', N'0832101234')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (8, N'Гюнтер Заксен', N'ул. Брегалница, студентско общежитие блок 3, стая 913', N'03451002002')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (9, N'Мелани Зафирова', N'кв. Победа, блок 11, вх. Г, ет. 4, ап. 14', N'0880110012')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (10, N'Манол Петков', N'кв. Чайка, блок 23, ет. 3, ап. 11', N'052112233')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (11, N'Иван Духовников', N'ул. Морска сирена 4, ет. 11, ап. 44', N'0912231321')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (12, N'Теодора Попова', N'ул. Тинтява № 18, ет. 2, ап. 4', N'0654087098')
INSERT [dbo].[Clients] ([ClientId], [Name], [Address], [Phone]) VALUES (13, N'Кристина Горанова', N'кв. Аспарухово, ул. Народни будители №16', N'0988101202')
SET IDENTITY_INSERT [dbo].[Clients] OFF
GO
SET IDENTITY_INSERT [dbo].[Courier] ON 

INSERT [dbo].[Courier] ([CourierId], [Name], [UCN], [Phone]) VALUES (1, N'Нина Галева', N'0348291012', N'0844890909')
INSERT [dbo].[Courier] ([CourierId], [Name], [UCN], [Phone]) VALUES (2, N'Митко Димов', N'0141145546', N'0989990099')
INSERT [dbo].[Courier] ([CourierId], [Name], [UCN], [Phone]) VALUES (3, N'Дани Боримечков', N'0343221144', N'0899222333')
INSERT [dbo].[Courier] ([CourierId], [Name], [UCN], [Phone]) VALUES (4, N'Бранимир Сендов', N'0251110921', N'0828800900')
INSERT [dbo].[Courier] ([CourierId], [Name], [UCN], [Phone]) VALUES (5, N'Ани Яворова', N'0045051213', N'0808070605')
INSERT [dbo].[Courier] ([CourierId], [Name], [UCN], [Phone]) VALUES (6, N'Васил Колев', N'9802286566', N'0881002003')
INSERT [dbo].[Courier] ([CourierId], [Name], [UCN], [Phone]) VALUES (7, N'Галин Тодоров', N'9912131441', N'0875500600')
SET IDENTITY_INSERT [dbo].[Courier] OFF
GO
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (1, 1)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (1, 2)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (1, 3)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (1, 5)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (1, 6)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (1, 7)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (1, 9)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (2, 4)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (2, 10)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (3, 8)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (4, 1)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (4, 2)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (4, 3)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (4, 4)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (4, 5)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (4, 6)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (4, 7)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (4, 8)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (4, 9)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (4, 10)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (5, 1)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (6, 2)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (6, 7)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (7, 1)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (7, 3)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (7, 5)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (7, 7)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (7, 8)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (8, 4)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (8, 6)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (9, 1)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (9, 4)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (9, 5)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (9, 7)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (10, 6)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (11, 6)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (11, 8)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (12, 1)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (12, 9)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (13, 10)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (14, 2)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (14, 5)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (14, 7)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (14, 8)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (14, 9)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (14, 10)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (15, 4)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (15, 8)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (16, 1)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (16, 5)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (17, 1)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (17, 4)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (18, 1)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (18, 4)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (18, 10)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (19, 4)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (19, 5)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (20, 10)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (21, 5)
INSERT [dbo].[Ingredients] ([IngredientId], [PizzaNameId]) VALUES (22, 5)
GO
SET IDENTITY_INSERT [dbo].[IngredientsNames] ON 

INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (1, N'доматен сос')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (2, N'сметанов сос')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (3, N'бял чеснов сос със спанак')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (4, N' моцарела')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (5, N' бяло сирене')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (6, N' шунка')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (7, N' маслини')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (8, N' топено сирене')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (9, N' пипер')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (10, N' чедър')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (11, N' синьо сирене')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (12, N' леко пикантен луканков салам')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (13, N' прошуто')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (14, N' гъби')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (15, N' пилешко филе')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (16, N' лук')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (17, N' бекон')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (18, N' пресен домат')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (19, N' царевица')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (20, N' зехтин с бял трюфел')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (21, N' тиквички')
INSERT [dbo].[IngredientsNames] ([IngredientId], [Name]) VALUES (22, N' броколи')
SET IDENTITY_INSERT [dbo].[IngredientsNames] OFF
GO
SET IDENTITY_INSERT [dbo].[Order] ON 

INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (1, 1, 1, CAST(N'2021-12-02' AS Date), CAST(N'16:48:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (2, 2, 2, CAST(N'2021-12-03' AS Date), CAST(N'12:43:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (3, 3, 3, CAST(N'2021-12-04' AS Date), CAST(N'21:36:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (4, 4, 4, CAST(N'2021-12-04' AS Date), CAST(N'23:02:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (5, 1, 5, CAST(N'2021-12-05' AS Date), CAST(N'19:40:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (6, 3, 6, CAST(N'2021-12-05' AS Date), CAST(N'21:21:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (7, 4, 3, CAST(N'2021-12-08' AS Date), CAST(N'10:48:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (8, 4, 1, CAST(N'2021-12-13' AS Date), CAST(N'11:02:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (9, 5, 7, CAST(N'2021-12-15' AS Date), CAST(N'16:33:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (10, 2, 8, CAST(N'2021-12-17' AS Date), CAST(N'23:16:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (11, 4, 9, CAST(N'2021-12-18' AS Date), CAST(N'11:02:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (12, 6, 2, CAST(N'2021-12-18' AS Date), CAST(N'19:12:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (13, 3, 8, CAST(N'2021-12-19' AS Date), CAST(N'15:21:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (14, 6, 3, CAST(N'2021-12-20' AS Date), CAST(N'17:31:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (15, 5, 4, CAST(N'2021-12-26' AS Date), CAST(N'22:33:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (16, 3, 3, CAST(N'2022-01-01' AS Date), CAST(N'12:57:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (17, 7, 10, CAST(N'2022-01-03' AS Date), CAST(N'22:33:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (18, 4, 5, CAST(N'2022-01-06' AS Date), CAST(N'17:45:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (19, 1, 9, CAST(N'2022-01-06' AS Date), CAST(N'18:57:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (20, 3, 11, CAST(N'2022-01-08' AS Date), CAST(N'22:33:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (21, 1, 4, CAST(N'2022-01-09' AS Date), CAST(N'17:02:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (22, 6, 1, CAST(N'2022-01-09' AS Date), CAST(N'20:52:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (23, 5, 12, CAST(N'2022-01-10' AS Date), CAST(N'23:55:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (24, 4, 13, CAST(N'2022-01-13' AS Date), CAST(N'12:28:00' AS Time))
INSERT [dbo].[Order] ([OrderId], [CourierId], [ClientId], [Date], [Hour]) VALUES (25, 4, 8, CAST(N'2022-01-14' AS Date), CAST(N'13:55:00' AS Time))
SET IDENTITY_INSERT [dbo].[Order] OFF
GO
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (1, 1, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (1, 5, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (1, 7, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (2, 8, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (2, 10, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (3, 15, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (3, 18, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (4, 3, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (4, 9, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (4, 19, 3)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (5, 19, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (5, 22, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (6, 6, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (6, 18, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (6, 27, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (7, 12, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (7, 16, 4)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (8, 7, 4)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (8, 16, 3)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (8, 20, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (9, 15, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (9, 16, 3)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (9, 25, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (10, 4, 3)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (10, 10, 4)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (10, 15, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (11, 11, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (11, 15, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (12, 10, 4)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (12, 16, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (13, 18, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (13, 21, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (14, 17, 3)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (15, 20, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (15, 29, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (15, 30, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (16, 26, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (16, 29, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (17, 6, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (17, 16, 3)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (17, 21, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (18, 13, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (18, 20, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (18, 28, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (19, 2, 3)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (19, 23, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (20, 26, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (21, 12, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (21, 16, 5)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (22, 21, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (23, 7, 3)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (23, 24, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (24, 14, 1)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (24, 19, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (25, 5, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (25, 11, 2)
INSERT [dbo].[OrderPizza] ([OrderId], [PizzaId], [Quantity]) VALUES (25, 24, 1)
GO
SET IDENTITY_INSERT [dbo].[Pizza] ON 

INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (1, 1, N'малка', 4.6000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (2, 1, N'средна', 7.2000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (3, 1, N'фамилна', 14.8000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (4, 2, N'малка', 4.3000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (5, 2, N'средна', 6.8000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (6, 2, N'фамилна', 14.5000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (7, 3, N'малка', 3.4000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (8, 3, N'средна', 5.4000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (9, 3, N'фамилна', 11.8000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (10, 4, N'малка', 4.6000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (11, 4, N'средна', 7.2000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (12, 4, N'фамилна', 14.8000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (13, 5, N'малка', 4.2000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (14, 5, N'средна', 6.6000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (15, 5, N'фамилна', 14.2000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (16, 6, N'малка', 3.6000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (17, 6, N'средна', 5.9000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (18, 6, N'фамилна', 13.2000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (19, 7, N'малка', 4.4000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (20, 7, N'средна', 6.8000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (21, 7, N'фамилна', 14.5000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (22, 8, N'малка', 4.6000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (23, 8, N'средна', 7.2000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (24, 8, N'фамилна', 14.8000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (25, 9, N'малка', 4.4000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (26, 10, N'малка', 4.8000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (27, 9, N'средна', 6.8000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (28, 10, N'средна', 7.4000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (29, 9, N'фамилна', 14.5000)
INSERT [dbo].[Pizza] ([PizzaId], [PizzaNameId], [Size], [Price]) VALUES (30, 10, N'фамилна', 15.2000)
SET IDENTITY_INSERT [dbo].[Pizza] OFF
GO
SET IDENTITY_INSERT [dbo].[PizzaName] ON 

INSERT [dbo].[PizzaName] ([PizzaNameId], [Name]) VALUES (1, N'Ел мафиозо')
INSERT [dbo].[PizzaName] ([PizzaNameId], [Name]) VALUES (2, N'Венеция')
INSERT [dbo].[PizzaName] ([PizzaNameId], [Name]) VALUES (3, N'Маргарита')
INSERT [dbo].[PizzaName] ([PizzaNameId], [Name]) VALUES (4, N'Тоскана')
INSERT [dbo].[PizzaName] ([PizzaNameId], [Name]) VALUES (5, N'Вегетариана')
INSERT [dbo].[PizzaName] ([PizzaNameId], [Name]) VALUES (6, N'Четири сирена')
INSERT [dbo].[PizzaName] ([PizzaNameId], [Name]) VALUES (7, N'Капричоза')
INSERT [dbo].[PizzaName] ([PizzaNameId], [Name]) VALUES (8, N'Бианка')
INSERT [dbo].[PizzaName] ([PizzaNameId], [Name]) VALUES (9, N'Милано')
INSERT [dbo].[PizzaName] ([PizzaNameId], [Name]) VALUES (10, N'Прошуто фунги')
SET IDENTITY_INSERT [dbo].[PizzaName] OFF
GO
ALTER TABLE [dbo].[Ingredients]  WITH CHECK ADD  CONSTRAINT [FK_Ingredients_IngredientsNames] FOREIGN KEY([IngredientId])
REFERENCES [dbo].[IngredientsNames] ([IngredientId])
GO
ALTER TABLE [dbo].[Ingredients] CHECK CONSTRAINT [FK_Ingredients_IngredientsNames]
GO
ALTER TABLE [dbo].[Ingredients]  WITH CHECK ADD  CONSTRAINT [FK_Ingredients_PizzaName] FOREIGN KEY([PizzaNameId])
REFERENCES [dbo].[PizzaName] ([PizzaNameId])
GO
ALTER TABLE [dbo].[Ingredients] CHECK CONSTRAINT [FK_Ingredients_PizzaName]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Clients] FOREIGN KEY([ClientId])
REFERENCES [dbo].[Clients] ([ClientId])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Clients]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Courier] FOREIGN KEY([CourierId])
REFERENCES [dbo].[Courier] ([CourierId])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Courier]
GO
ALTER TABLE [dbo].[OrderPizza]  WITH CHECK ADD  CONSTRAINT [FK_OrderPizza_Order] FOREIGN KEY([OrderId])
REFERENCES [dbo].[Order] ([OrderId])
GO
ALTER TABLE [dbo].[OrderPizza] CHECK CONSTRAINT [FK_OrderPizza_Order]
GO
ALTER TABLE [dbo].[OrderPizza]  WITH CHECK ADD  CONSTRAINT [FK_OrderPizza_Pizza] FOREIGN KEY([PizzaId])
REFERENCES [dbo].[Pizza] ([PizzaId])
GO
ALTER TABLE [dbo].[OrderPizza] CHECK CONSTRAINT [FK_OrderPizza_Pizza]
GO
ALTER TABLE [dbo].[Pizza]  WITH CHECK ADD  CONSTRAINT [FK_Pizza_PizzaName] FOREIGN KEY([PizzaNameId])
REFERENCES [dbo].[PizzaName] ([PizzaNameId])
GO
ALTER TABLE [dbo].[Pizza] CHECK CONSTRAINT [FK_Pizza_PizzaName]
GO
/****** Object:  StoredProcedure [dbo].[usp_Clients_Insert]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   procedure [dbo].[usp_Clients_Insert](@ClientName nvarchar(30),@ClientAddress nvarchar(100),@ClientPhone nvarchar(12))
as 
Begin
	if(ISNUMERIC(@ClientPhone)=1 AND @ClientPhone not in (select Phone from Clients) and @ClientName is not null and @ClientAddress is not null and @ClientPhone is not null)
		begin
		insert into Clients
		values(@ClientName,@ClientAddress,@ClientPhone)
		Print Concat('Successfully added new client: ',@ClientName)
		end
else print 'Invalid string'
end
GO
/****** Object:  StoredProcedure [dbo].[usp_Ingredients_Delete]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[usp_Ingredients_Delete](@DeleteIngredientName nvarchar(32), @PizzaName nvarchar(32))
AS
BEGIN
	DECLARE @DeleteIngredientId int = (SELECT I.IngredientId FROM Ingredients as I join IngredientsNames as INS on I.IngredientId = INS.IngredientId WHERE INS.Name = @DeleteIngredientName)
	DECLARE @PizzaId int = (SELECT PN.PizzaNameId FROM Ingredients as I join PizzaName as PN on I.PizzaNameId = PN.PizzaNameId WHERE PN.Name = @PizzaName)
	IF((@PizzaId IN 
	(
		SELECT PizzaNameId
		FROM Ingredients
	)OR @PizzaName IS NULL) AND
	@DeleteIngredientId IN 
	(
		SELECT IngredientId
		FROM Ingredients
		WHERE PizzaNameId = @PizzaId
	))
	BEGIN
		DELETE
		FROM Ingredients
		WHERE IngredientId = @DeleteIngredientId AND (PizzaNameId = @PizzaId OR @PizzaName IS NULL)
		PRINT CONCAT('Successfully deletet ingredient ' , @DeleteIngredientName, ' from ' , ISNULL('ALL Pizzas',@PizzaName))
	END
	ELSE PRINT 'Invalid string'
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Ingredients_Insert]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[usp_Ingredients_Insert](@IngredientName nvarchar(32), @PizzaName nvarchar(32))
AS
BEGIN
	DECLARE @IngredientId int = (SELECT I.IngredientId FROM Ingredients as I join IngredientsNames as INS on I.IngredientId = INS.IngredientId WHERE INS.Name = @IngredientName)
	DECLARE @PizzaId int = (SELECT PN.PizzaNameId FROM Ingredients as I join PizzaName as PN on I.PizzaNameId = PN.PizzaNameId WHERE PN.Name = @PizzaName)
	IF(
		@PizzaId IS NOT NULL 
		AND @IngredientId IS NOT NULL 
		AND @IngredientId NOT IN 
		(
			SELECT IngredientId 
			FROM Ingredients 
			WHERE PizzaNameId = @PizzaId
		)
	   )
	BEGIN
		INSERT INTO Ingredients
		VALUES (@IngredientId,@PizzaId)
		PRINT CONCAT('Successfully inserted ' ,@PizzaName ,'-' ,@IngredientName)
	END
	ELSE PRINT 'Invalid string'
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Ingredients_Update]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[usp_Ingredients_Update](@NewIngredientName nvarchar(32), @OldIngredientName nvarchar(32), @PizzaName nvarchar(32))
AS
BEGIN
	DECLARE @OldIngredientId int = (SELECT I.IngredientId FROM Ingredients as I join IngredientsNames as INS on I.IngredientId = INS.IngredientId WHERE INS.Name = @OldIngredientName)
	DECLARE @NewIngredientId int = (SELECT I.IngredientId FROM Ingredients as I join IngredientsNames as INS on I.IngredientId = INS.IngredientId WHERE INS.Name = @NewIngredientName)
	DECLARE @PizzaId int = (SELECT PN.PizzaNameId FROM Ingredients as I join PizzaName as PN on I.PizzaNameId = PN.PizzaNameId WHERE PN.Name = @PizzaName)
	IF((@PizzaId IN 
	(
		SELECT PizzaNameId
		FROM Ingredients
	)OR @PizzaName IS NULL) AND
	@OldIngredientId IN 
	(
		SELECT IngredientId
		FROM Ingredients
		WHERE PizzaNameId = @PizzaId
	) AND 
	@OldIngredientId NOT IN 
	(
		SELECT IngredientId
		FROM Ingredients
		WHERE PizzaNameId = @PizzaId
	))
	BEGIN
		UPDATE Ingredients
		SET IngredientId = @NewIngredientId
		WHERE IngredientId = @OldIngredientId AND (PizzaNameId = @PizzaId OR @PizzaName IS NULL)
		PRINT CONCAT('Successfully updated ingredient of ' , ISNULL('ALL Pizzas',@PizzaName),' from ',@OldIngredientName, 'to' ,@NewIngredientName)
	END
	ELSE PRINT 'Invalid string'
END
GO
/****** Object:  StoredProcedure [dbo].[usp_IngredientsNames_Delete]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[usp_IngredientsNames_Delete](@DeletedIngredientName nvarchar(32))
AS
BEGIN
	IF(@DeletedIngredientName IN (SELECT Name FROM IngredientsNames))
	BEGIN
		IF(@DeletedIngredientName IN 
			(SELECT INS.Name 
			FROM Ingredients as I 
			left join IngredientsNames as INS 
			on I.IngredientId = INS.IngredientId))
		BEGIN
			PRINT 'Ingredinet is used in IngredinetsNames'
		END
		ELSE
			BEGIN
			DELETE FROM 
			IngredientsNames 
			WHERE Name = @DeletedIngredientName
			PRINT CONCAT('Successfully deleted ingredient: ', @DeletedIngredientName)
		END
	END
	ELSE Print 'Invalid string'
END
GO
/****** Object:  StoredProcedure [dbo].[usp_IngredientsNames_Insert]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_IngredientsNames_Insert]
(
	@NewIngredientName nvarchar(32)
)
AS
BEGIN
	IF(@NewIngredientName NOT IN (SELECT Name FROM IngredientsNames) AND @NewIngredientName IS NOT NULL)
	BEGIN
		Insert Into IngredientsNames 
		(Name)
		Values
		(@NewIngredientName)
		PRINT CONCAT('Successfully added new ingredient: ', @NewIngredientName)
	END
	ELSE PRINT 'Invalid string'
END
GO
/****** Object:  StoredProcedure [dbo].[usp_IngredientsNames_Update]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[usp_IngredientsNames_Update](@NewIngredientName nvarchar(32),@OldIngredientName nvarchar(32))
AS
BEGIN
	IF(@OldIngredientName IN (SELECT Name FROM IngredientsNames) AND @NewIngredientName NOT IN (SELECT Name FROM IngredientsNames))
	BEGIN
		UPDATE IngredientsNames
		SET Name = @NewIngredientName
		WHERE Name = @OldIngredientName
		PRINT CONCAT('Successfully updated ', @OldIngredientName ,' to : ', @NewIngredientName)
	END
	ELSE Print 'Invalid string'
END
GO
/****** Object:  StoredProcedure [dbo].[usp_PizzaName_Delete]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[usp_PizzaName_Delete](@DeletePizzaName nvarchar(32))
AS
BEGIN
	IF(@DeletePizzaName IN 
	(
		SELECT Name 
		FROM PizzaName
	) AND 
	@DeletePizzaName NOT IN 
	(
		SELECT Name 
		FROM Ingredients as I 
		left join PizzaName as PN on PN.PizzaNameId = I.PizzaNameId
	))
	BEGIN
		DELETE 
		FROM PizzaName 
		WHERE Name = @DeletePizzaName
		PRINT CONCAT('Successfully deleted PizzaName: ',@DeletePizzaName)
	END
	ELSE PRINT 'Invalid string'
END
GO
/****** Object:  StoredProcedure [dbo].[usp_PizzaName_Insert]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[usp_PizzaName_Insert](@NewName nvarchar(32))
AS
BEGIN
	IF(@NewName NOT IN (SELECT Name FROM PizzaName))
	BEGIN
		INSERT INTO PizzaName
		(Name)
		VALUES
		(@NewName)
		PRINT CONCAT('Successfully added new pizza name: ',@NewName)
	END
	ELSE PRINT 'Invalid string'
END
GO
/****** Object:  StoredProcedure [dbo].[usp_PizzaName_Update]    Script Date: 1/29/2024 11:33:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[usp_PizzaName_Update](@NewPizzaName nvarchar(32), @OldPizzaName nvarchar(32))
AS
BEGIN
	IF(@OldPizzaName IN 
	(
		SELECT Name 
		FROM PizzaName
	) AND 
	@NewPizzaName NOT IN 
	(
		SELECT Name 
		FROM PizzaName
	))
	BEGIN
		UPDATE PizzaName
		SET Name = @NewPizzaName
		WHERE Name = @OldPizzaName
		PRINT CONCAT('Successfully updated PizzaName ' , @OldPizzaName,' to: ',@NewPizzaName)
	END
	ELSE PRINT 'Invalid string'
END
GO
USE [master]
GO
ALTER DATABASE [DaHapnemDB] SET  READ_WRITE 
GO
