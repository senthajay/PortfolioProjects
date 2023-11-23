
------Cleaning the housing data -----

SELECT  TOP(1000) *
From NashvileHousing


------Standard time formatting------
SELECT SaleDateConverted,CONVERT(Date,SaleDate) AS SaleDateConeverted
From NashvileHousing

ALTER TABLE NashvileHousing
ADD SaleDateConverted Date;

UPDATE NashvileHousing
Set SaleDateConverted = CONVERT(Date,SaleDate) 

----------Property Address data------

SELECT  *
From NashvileHousing
WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvileHousing a 
JOIN NashvileHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvileHousing a 
JOIN NashvileHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

---- Breaking out address into (Address, City, State)----

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS ADDRESS,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS ADDRESS
From NashvileHousing

ALTER TABLE NashvileHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvileHousing
Set PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvileHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvileHousing
Set PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

---Now split the owner address---

SELECT OwnerAddress
FROM NashvileHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvileHousing


ALTER TABLE NashvileHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvileHousing
Set OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvileHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvileHousing
Set OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvileHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvileHousing
Set OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM NashvileHousing

------Change Y and N to 'Yes' and 'No'---
SELECT SoldAsVacant, COUNT(SoldAsVacant) AS Count_data
FROM NashvileHousing
Group By(SoldAsVacant)
Order by Count_data


SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
END

FROM NashvileHousing

UPDATE NashvileHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
END

FROM NashvileHousing


-------REMOVE DUPLICATES ----------



WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS Row_Num
    FROM NashvileHousing
)

SELECT *
FROM RowNumCTE
WHERE Row_Num >1
ORDER BY PropertyAddress







------- REMOVE UNUSED COLUMNS------------------

SELECT *
FROM NashvileHousing

ALTER TABLE NashvileHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict