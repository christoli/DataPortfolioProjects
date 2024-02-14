--Cleaning Data in SQL Queries

Select * 
From PortfolioProject..NashvilleHousing


--Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

--Update NashvilleHousing
--SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



--Populate Property Address data


Select *
From PortfolioProject..NashvilleHousing
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject..NashvilleHousing
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject..NashvilleHousing



Select OwnerAddress
From PortfolioProject..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing


ALTER TABLE [dbo].[NashvilleHousing]
add OwnerSpliteAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSpliteAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
	, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		   When SoldAsVacant = 'N' THEN 'No'
		   ELSE SoldAsVacant
		   END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		   When SoldAsVacant = 'N' THEN 'No'
		   ELSE SoldAsVacant
		   END
From NashvilleHousing



--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
From NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



--Delete Unused Colomns

Select *
From NashvilleHousing

ALTER TABLE PortfolioProject.[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.[dbo].[NashvilleHousing]
DROP COLUMN SaleDate


