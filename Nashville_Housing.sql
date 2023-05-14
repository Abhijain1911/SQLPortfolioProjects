--DATA CLEANING

SELECT *
FROM PortfolioProjects..NashvilleHousing

--Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
ADD SaleDateConverted Date

UPDATE PortfolioProjects..NashvilleHousing 
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM PortfolioProjects..NashvilleHousing


--Populate Property Address

SELECT *
FROM PortfolioProjects..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking out Address into Individual Coulumns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHousing

--METHOD-1 by using SUBSTRING

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS ADDRESS,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS CITY
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE PortfolioProjects..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProjects..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE PortfolioProjects..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * 
FROM PortfolioProjects..NashvilleHousing


--METHOD-2 by using PARSENAME

SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE PortfolioProjects..NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProjects..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE PortfolioProjects..NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProjects..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProjects..NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM PortfolioProjects..NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'YES'
	 WHEN SoldAsVacant='N' THEN 'NO'
	 ELSE SoldAsVacant
END
FROM PortfolioProjects..NashvilleHousing

UPDATE PortfolioProjects..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'YES'
	 WHEN SoldAsVacant='N' THEN 'NO'
	 ELSE SoldAsVacant
END


--Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID
) row_num
FROM PortfolioProjects..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num>1


--Delete Unused Columns

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
