USE [master]
GO
/****** Object:  Database [LibraryDB]    Script Date: 15/04/2023 01:33:19 ******/
CREATE DATABASE [LibraryDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'LibraryDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\LibraryDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'LibraryDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\LibraryDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [LibraryDB] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [LibraryDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [LibraryDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [LibraryDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [LibraryDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [LibraryDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [LibraryDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [LibraryDB] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [LibraryDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [LibraryDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [LibraryDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [LibraryDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [LibraryDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [LibraryDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [LibraryDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [LibraryDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [LibraryDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [LibraryDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [LibraryDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [LibraryDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [LibraryDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [LibraryDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [LibraryDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [LibraryDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [LibraryDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [LibraryDB] SET  MULTI_USER 
GO
ALTER DATABASE [LibraryDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [LibraryDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [LibraryDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [LibraryDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [LibraryDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [LibraryDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [LibraryDB] SET QUERY_STORE = ON
GO
ALTER DATABASE [LibraryDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [LibraryDB]
GO
/****** Object:  Table [dbo].[Library_Catalogue_Items]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Library_Catalogue_Items](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[ItemTitle] [nvarchar](50) NOT NULL,
	[ItemType] [nvarchar](50) NOT NULL,
	[Author] [nvarchar](50) NOT NULL,
	[YearofPublication] [smallint] NOT NULL,
	[DateAddedtoCcollection] [date] NOT NULL,
	[CurrentStatus] [nvarchar](20) NOT NULL,
	[ISBN] [nvarchar](13) NULL,
	[DateIdentifiedLost] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Loans_History]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Loans_History](
	[LoanID] [int] IDENTITY(1,1) NOT NULL,
	[MemberID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[LoanDate] [date] NOT NULL,
	[DueDate] [date] NOT NULL,
	[ReturnDate] [date] NULL,
	[OverdueFees] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[LoanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetItemsDueSoon]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetItemsDueSoon]()
RETURNS TABLE
AS
RETURN
(
    SELECT c.ItemID, c.ItemTitle, c.ItemType, c.Author, l.LoanID, l.LoanDate, l.DueDate, l.ReturnDate, DATEDIFF(DAY, GETDATE(), l.DueDate) AS DaysRemaining
    FROM Library_Catalogue_Items c
    INNER JOIN Loans_History l ON c.ItemID = l.ItemID
    WHERE l.ReturnDate IS NULL
    AND DATEDIFF(DAY, GETDATE(), l.DueDate) < 5
);
GO
/****** Object:  Table [dbo].[Members]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Members](
	[MemberID] [int] IDENTITY(1,1) NOT NULL,
	[MemberFirstName] [nvarchar](50) NOT NULL,
	[MemberMiddleName] [nvarchar](50) NOT NULL,
	[MemberLastName] [nvarchar](50) NOT NULL,
	[MemberAddressID] [int] NOT NULL,
	[MemberDOB] [date] NOT NULL,
	[MemberEmail] [nvarchar](100) NULL,
	[MemberPhone] [nvarchar](20) NULL,
	[MemberUsername] [nvarchar](20) NOT NULL,
	[MemberPassword] [nvarchar](20) NOT NULL,
	[MembershipEndDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[MemberEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[LoanHistory]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[LoanHistory] AS
SELECT LH.LoanID,
       M.MemberID,
       M.MemberFirstName,
       M.MemberMiddleName,
       M.MemberLastName,
       LCI.ItemID,
       LCI.ItemTitle,
       LH.LoanDate AS BorrowedDate,
       LH.DueDate,
       LH.OverdueFees AS FineAmount
FROM Loans_History LH
INNER JOIN Members M ON LH.MemberID = M.MemberID
INNER JOIN Library_Catalogue_Items LCI ON LH.ItemID = LCI.ItemID;
GO
/****** Object:  View [dbo].[TotalLoansOnSpecificDate]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TotalLoansOnSpecificDate] AS
SELECT COUNT(*) AS TotalLoans
FROM Loans_History
GROUP BY LoanDate;
GO
/****** Object:  Table [dbo].[Address]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Address](
	[MemberAddressID] [int] IDENTITY(1,1) NOT NULL,
	[Address1] [nvarchar](50) NOT NULL,
	[Address2] [nvarchar](50) NULL,
	[City] [nvarchar](50) NULL,
	[Postcode] [nvarchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MemberAddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Fine_Repayment]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Fine_Repayment](
	[FineID] [int] IDENTITY(1,1) NOT NULL,
	[MemberID] [int] NOT NULL,
	[RepaymentDate] [date] NOT NULL,
	[Amount] [money] NOT NULL,
	[RepaymentMethod] [varchar](5) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[FineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Item_Current_Status]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Item_Current_Status](
	[ItemCurrentStatusID] [int] IDENTITY(1,1) NOT NULL,
	[ItemID] [int] NOT NULL,
	[Status] [varchar](15) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ItemCurrentStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Overdue_Fines]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Overdue_Fines](
	[OverdueFinesID] [int] IDENTITY(1,1) NOT NULL,
	[MemberID] [int] NOT NULL,
	[TotalFineOwed] [money] NOT NULL,
	[TotalFineRepaid] [money] NOT NULL,
	[OutstandingBalance] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[OverdueFinesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Fine_Repayment]  WITH CHECK ADD  CONSTRAINT [FK_MemberID] FOREIGN KEY([MemberID])
REFERENCES [dbo].[Members] ([MemberID])
GO
ALTER TABLE [dbo].[Fine_Repayment] CHECK CONSTRAINT [FK_MemberID]
GO
ALTER TABLE [dbo].[Item_Current_Status]  WITH CHECK ADD FOREIGN KEY([ItemID])
REFERENCES [dbo].[Library_Catalogue_Items] ([ItemID])
GO
ALTER TABLE [dbo].[Loans_History]  WITH CHECK ADD FOREIGN KEY([ItemID])
REFERENCES [dbo].[Library_Catalogue_Items] ([ItemID])
GO
ALTER TABLE [dbo].[Loans_History]  WITH CHECK ADD FOREIGN KEY([MemberID])
REFERENCES [dbo].[Members] ([MemberID])
GO
ALTER TABLE [dbo].[Members]  WITH CHECK ADD FOREIGN KEY([MemberAddressID])
REFERENCES [dbo].[Address] ([MemberAddressID])
GO
ALTER TABLE [dbo].[Overdue_Fines]  WITH CHECK ADD  CONSTRAINT [FK_Overdue_Fines_Members] FOREIGN KEY([MemberID])
REFERENCES [dbo].[Members] ([MemberID])
GO
ALTER TABLE [dbo].[Overdue_Fines] CHECK CONSTRAINT [FK_Overdue_Fines_Members]
GO
ALTER TABLE [dbo].[Members]  WITH CHECK ADD CHECK  (([MEMBERDOB]>='1905-01-01' AND [MEMBERDOB]<=getdate()))
GO
ALTER TABLE [dbo].[Members]  WITH CHECK ADD CHECK  (([MemberEmail] like '%_@_%._%'))
GO
/****** Object:  StoredProcedure [dbo].[InsertNewMember]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertNewMember]
    @MemberFirstName NVARCHAR(50),
    @MemberMiddleName NVARCHAR(50),
    @MemberLastName NVARCHAR(50),
    @MemberAddressID INT,
    @MemberDOB DATE,
    @MemberEmail NVARCHAR(100),
    @MemberPhone NVARCHAR(20),
    @MemberUsername NVARCHAR(20),
    @MemberPassword NVARCHAR(20),
    @MembershipEndDate DATE
AS
BEGIN
    -- Check if required fields are not null
    IF @MemberFirstName IS NULL OR @MemberLastName IS NULL OR @MemberAddressID IS NULL
        OR @MemberDOB IS NULL OR @MemberEmail IS NULL OR @MemberPhone IS NULL
        OR @MemberUsername IS NULL OR @MemberPassword IS NULL
    BEGIN
        RAISERROR('All fields are required.', 16, 1);
        RETURN;
    END

    -- Check for duplicate username
    IF EXISTS (SELECT 1 FROM Member WHERE MemberUsername = @MemberUsername)
    BEGIN
        RAISERROR('Username already exists. Please choose a different username.', 16, 1);
        RETURN;
    END

    -- Insert new member into database
    INSERT INTO Member (MemberFirstName, MemberMiddleName, MemberLastName, MemberAddressID, MemberDOB,
                        MemberEmail, MemberPhone, MemberUsername, MemberPassword, MembershipEndDate)
    VALUES (@MemberFirstName, @MemberMiddleName, @MemberLastName, @MemberAddressID, @MemberDOB,
            @MemberEmail, @MemberPhone, @MemberUsername, @MemberPassword, @MembershipEndDate);

    PRINT 'New member has been inserted successfully.';
END
GO
/****** Object:  StoredProcedure [dbo].[SearchCatalogue]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE PROCEDURE [dbo].[SearchCatalogue]
    @ItemTitle NVARCHAR(50)
AS
BEGIN
    SELECT ItemID, ItemTitle, ItemType, Author, YearofPublication, ISBN
    FROM  Library_Catalogue_Items
    WHERE ItemTitle LIKE '%' + @ItemTitle + '%'
    ORDER BY  YearofPublication DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateMember]    Script Date: 15/04/2023 01:33:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateMember]
    @MemberID INT,
    @MemberFirstName NVARCHAR(50),
    @MemberMiddleName NVARCHAR(50),
    @MemberLastName NVARCHAR(50),
    @MemberAddressID INT,
    @MemberDOB DATE,
    @MemberEmail NVARCHAR(100),
    @MemberPhone NVARCHAR(20),
    @MemberUsername NVARCHAR(20),
    @MemberPassword NVARCHAR(20),
    @MembershipEndDate DATE
AS
BEGIN
    -- Update the member in the Members table
    UPDATE Members
    SET MemberFirstName = @MemberFirstName,
        MemberMiddleName = @MemberMiddleName,
        MemberLastName = @MemberLastName,
        MemberAddressID = @MemberAddressID,
        MemberDOB = @MemberDOB,
        MemberEmail = @MemberEmail,
        MemberPhone = @MemberPhone,
        MemberUsername = @MemberUsername,
        MemberPassword = @MemberPassword,
        MembershipEndDate = @MembershipEndDate
    WHERE MemberID = @MemberID;
    
    -- Check for any errors during the update
    IF @@ERROR <> 0
    BEGIN
        RAISERROR('Error occurred while updating member. Please check the input parameters.', 16, 1);
        RETURN;
    END
END
GO
USE [master]
GO
ALTER DATABASE [LibraryDB] SET  READ_WRITE 
GO
