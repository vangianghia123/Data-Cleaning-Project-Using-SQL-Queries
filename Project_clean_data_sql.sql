﻿
/*

Làm sạch dữ liệu bằng SQL

*/


SELECT * FROM Nvilehouse.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------
-- chuẩn hóa Date format


Update Nvilehouse.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nvilehouse.dbo.[NashvilleHousing]
ADD SaleDateFormatted DATE;

UPDATE Nvilehouse.dbo.[NashvilleHousing]
SET SaleDateFormatted = CONVERT(DATE, SaleDate, 101); 



 --------------------------------------------------------------------------------------------------------------------------

-- Điền dữ liệu bị missing của PropertyAdress

Select * From Nvilehouse.dbo.[NashvilleHousing]
Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nvilehouse.dbo.NashvilleHousing a
JOIN Nvilehouse.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nvilehouse.dbo.[NashvilleHousing] a
JOIN Nvilehouse.dbo.[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Chia dữ liệu cột Address thành các cột thành phần (Address, City, State)


Select PropertyAddress
From Nvilehouse.dbo.[NashvilleHousing]
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From Nvilehouse.dbo.[NashvilleHousing]


ALTER TABLE Nvilehouse.dbo.[NashvilleHousing]
Add PropertySplitAddress Nvarchar(255);

Update Nvilehouse.dbo.[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Nvilehouse.dbo.[NashvilleHousing]
Add PropertySplitCity Nvarchar(255);

Update Nvilehouse.dbo.[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From Nvilehouse.dbo.[NashvilleHousing]





Select OwnerAddress
From Nvilehouse.dbo.[NashvilleHousing]


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Nvilehouse.dbo.[NashvilleHousing]



ALTER TABLE Nvilehouse.dbo.[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update Nvilehouse.dbo.[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nvilehouse.dbo.[NashvilleHousing]
Add OwnerSplitCity Nvarchar(255);

Update Nvilehouse.dbo.[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nvilehouse.dbo.[NashvilleHousing]
Add OwnerSplitState Nvarchar(255);

Update Nvilehouse.dbo.[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Nvilehouse.dbo.[NashvilleHousing]




--------------------------------------------------------------------------------------------------------------------------


-- Thay đổi Y và N thành Yes và No trong cột "Sold as Vacant" 


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nvilehouse.dbo.[NashvilleHousing]
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Nvilehouse.dbo.[NashvilleHousing]


Update Nvilehouse.dbo.[NashvilleHousing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- loại bỏ giá trị trùng lặp

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDateFormatted ,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM Nvilehouse.dbo.[NashvilleHousing]
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;







Select *
From Nvilehouse.dbo.[NashvilleHousing]




---------------------------------------------------------------------------------------------------------

-- Xóa cột không sử dụng



Select *
From Nvilehouse.dbo.[NashvilleHousing]


ALTER TABLE Nvilehouse.dbo.[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















