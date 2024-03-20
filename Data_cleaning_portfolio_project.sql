select * from NashvilleHousing


/* Data Cleaning */
--------------------

--standardize date

select SaleDate, cast(SaleDate as Date) from NashvilleHousing

alter table NashvilleHousing
add  saleDateConverted Date;

update NashvilleHousing
SET saleDateConverted = CAST(SaleDate as Date)

select saleDateConverted, cast(SaleDate as Date) from NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------------

--populate property adress data

select * 
from NashvilleHousing 
order by ParcelID
--where PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out address into individual columns

select PropertyAddress
from NashvilleHousing

select SUBSTRING(PropertyAddress,1, CHARINDEX(',' , PropertyAddress) -1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 ,LEN(PropertyAddress)) as address
from NashvilleHousing

alter table NashvilleHousing
add street_name nvarchar(255);

update NashvilleHousing
set street_name = SUBSTRING(PropertyAddress,1, CHARINDEX(',' , PropertyAddress) -1)


alter table NashvilleHousing
add City_name nvarchar(255);

update NashvilleHousing
set City_name = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 ,LEN(PropertyAddress))

select street_name, City_name from NashvilleHousing;

----------------------------------------------------

select OwnerAddress
from NashvilleHousing

--select
--PARSENAME(replace(OwnerAddress, ',' , '.'),3) as Street_Name,
--PARSENAME(replace(OwnerAddress, ',' , '.'),2) as City_Name,
--PARSENAME(replace(OwnerAddress, ',' , '.'),1) as State_Name
--from NashvilleHousing

--alter table NashvilleHousing
--drop column Property_Street_Name;

--alter table NashvilleHousing
--drop column Property_City_Name, Property_State_Name ;

--select * from NashvilleHousing

alter table NashvilleHousing
add Owner_Street_Name nvarchar(255);

update NashvilleHousing
set Owner_Street_Name = PARSENAME(replace(OwnerAddress, ',' , '.'),3)


alter table NashvilleHousing
add Owner_City_Name nvarchar(255);

update NashvilleHousing
set Owner_City_Name = PARSENAME(replace(OwnerAddress, ',' , '.'),2)


alter table NashvilleHousing
add Owner_State_Name nvarchar(255);

update NashvilleHousing
set Owner_State_Name = PARSENAME(replace(OwnerAddress, ',' , '.'),1)

--select OwnerAddress, Owner_Street_Name, Owner_City_Name, Owner_State_Name
--from NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N in 'Sold as vacant' :

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by COUNT(SoldAsVacant)

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 end
from NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						end

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates:


with DuplicateDataCTE as(
select *,
		ROW_NUMBER() over (
		partition by ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 order by
						uniqueID
						) row_num
from NashvilleHousing
)
--select *
--from DuplicateDataCTE
--where row_num > 1
--order by PropertyAddress
delete
from DuplicateDataCTE
where row_num > 1

----------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete unused columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column SaleDate
