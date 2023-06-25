 SELECT *
 FROM PortfolioProject..NashvilleHousing

 --STANDARDIZE DATE FORMAT
 ---------------------------------------------------------------------------------------

 SELECT SaleDate
 FROM PortfolioProject..NashvilleHousing
 
 UPDATE PortfolioProject..NashvilleHousing
 SET SaleDate = CONVERT(date,SaleDate)

 ALTER TABLE NashvilleHousing
 ADD SaleDateConverted date

 UPDATE PortfolioProject..NashvilleHousing
 SET SaleDateConverted = CONVERT(date,SaleDate)

 --POPULATE PROPERTY ADDRESS DATA
 ---------------------------------------------------------------------------------
  
  SELECT *
  FROM PortfolioProject..NashvilleHousing
 -- WHERE PropertyAddress IS NULL
  ORDER BY ParcelID
  

  SELECT --TOP(200)
  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM PortfolioProject..NashvilleHousing a
  JOIN PortfolioProject..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM PortfolioProject..NashvilleHousing a
  JOIN PortfolioProject..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--BREAKING ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
----------------------------------------------------------------------------------------

  SELECT PropertyAddress
  FROM PortfolioProject..NashvilleHousing
 -- WHERE PropertyAddress IS NULL
 -- ORDER BY ParcelID

 SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City

 FROM PortfolioProject..NashvilleHousing


 ALTER TABLE NashvilleHousing
 ADD PropertySplitAddresss nvarchar(255)

 UPDATE PortfolioProject..NashvilleHousing
 SET PropertySplitAddresss = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
 

  ALTER TABLE NashvilleHousing
 ADD PropertySplitCity nvarchar(255)

 UPDATE PortfolioProject..NashvilleHousing
 SET PropertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

 SELECT * 
 FROM PortfolioProject..NashvilleHousing




SELECT OwnerAddress
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing
WHERE OwnerAddress IS NOT NULL




ALTER TABLE NashvilleHousing
 ADD OwnerSplitAddresss nvarchar(255)

 UPDATE PortfolioProject..NashvilleHousing
 SET OwnerSplitAddresss = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
 

  ALTER TABLE NashvilleHousing
 ADD OwnerSplitCity nvarchar(255)

 UPDATE PortfolioProject..NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
 ADD OwnerSplitState nvarchar(255)

 UPDATE PortfolioProject..NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

 SELECT * 
 FROM PortfolioProject..NashvilleHousing


 ----------------------------------------------------------------------------------------------------------------
 --CHANGE 'Y' AND 'N' TO 'YES' AND 'NO' IN 'SOLD AS VACANT' FIELD 

 
 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM PortfolioProject..NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2


 SELECT SoldAsVacant,
 CASE	
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE	
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

---------------------------------------------------------------------------------------------------------------------
--REMOVE DUPLICATES

WITH  Row_Num_CTE AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 Saledate,
			 LegalReference
			 ORDER BY UniqueID
			 ) Row_Num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
sELECT *
FROM Row_Num_CTE
WHERE Row_Num > 1
--ORDER BY PropertyAddress




 ----------------------------------------------------------------------------------------------------------------------------
 --DELETE UNUSED COLUMNS

 SELECT *
 FROM PortfolioProject..NashvilleHousing

 ALTER TABLE PortfolioProject..NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 ALTER TABLE PortfolioProject..NashvilleHousing
 DROP COLUMN SaleDate

