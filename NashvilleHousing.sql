-- Clearing Data in SQL Queries

select * from NashvilleHousing


-- Standardize Date Format

select SaleDateConverted, convert(Date, SaleDate) 
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(Date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)

-- Populate Property Address Data

select * 
from NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress 
from NashvilleHousing
-- where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress) +1, len(propertyaddress)) as Address
from NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress) -1)


alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress) +1, len(propertyaddress))


select *
from NashvilleHousing

select OwnerAddress
from NashvilleHousing

select
PARSENAME (Replace(OwnerAddress, ',', '.'),3),
PARSENAME (Replace(OwnerAddress, ',', '.'),2),
PARSENAME (Replace(OwnerAddress, ',', '.'),1)
from NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME (Replace(OwnerAddress, ',', '.'),3)



alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME (Replace(OwnerAddress, ',', '.'),2)



alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME (Replace(OwnerAddress, ',', '.'),1)



select *
from NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end


-- Remove Duplicates 

with RowNumCTE as(
select *, 
	ROW_NUMBER() over (
	Partition by ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
from NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

delete 
from RowNumCTE
where row_num > 1
--order by PropertyAddress



-- Delete Unused Columns

select *
from NashvilleHousing


alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate

