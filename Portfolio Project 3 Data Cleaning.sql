
/* 

Cleaning Data in SQL Queries

*/




--Let's check what do we have in here

SELECT *
FROM NashvilleHousing;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



/*

1) Standardise Date Format

*/

-- Adding a new column for SaleDate in Date format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

-- Filling the new column with relevant Data

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*

2) Populate Property Address data

*/

-- Fetching relevant PropertAddresses where the column is null,using Self Join


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Filling the Null Rows with Relevant Values


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 

3) Breaking Out Address into Individual Columns (Address,City,State)

*/

-- Starting Out with PropertyAddress


SELECT PropertyAddress
FROM NashvilleHousing;


-- Specifying what do we want


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashvilleHousing


-- Adding 2 new columns to the table


ALTER TABLE NashvilleHousing
ADD PropertyAddressNew NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR(255);


-- Filling those 2 new columns with the relevant values


UPDATE NashvilleHousing
SET PropertyAddressNew = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) FROM NashvilleHousing;

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));


-- Splitting the OwnerAddress column now


Select OwnerAddress from NashvilleHousing;


-- Specifying what we want


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing;


-- Adding 3 new columns 


ALTER TABLE NashvilleHousing
ADD OwnerAddressNew NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerState NVARCHAR(255)


-- Filling the 3 columns with relevant values


UPDATE NashvilleHousing
SET OwnerAddressNew = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 

4) Change Y and N to Yes and No in 'Sold as Vacant' field

*/



-- Checking what all values are there in SoldAsVacant Column


SELECT DISTINCT (SoldAsVacant)
FROM NashvilleHousing


-- Making relevant changes


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END

------------------------------------------------------------------------------------------------------------------------

/*

Remove Duplicates

*/

-- Identifying duplicates using Row_Number function and CTE
-- Deleting duplicates


With RowNumcte AS
(SELECT  * ,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SaleDate,
			SaLePrice,
			LegalReference
			ORDER BY UniqueID) Rownum
FROM NashvilleHousing) 
DELETE
FROM RowNumcte
WHERE Rownum>1

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*

Delete Unused Columns

*/


ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Have a final look at the Cleaned Data

SELECT * 
FROM NashvilleHousing; 











