select * from [dbo].[NashVilleHousing]




-- Standardlize Date format

select SaleDate, CONVERT(date,SaleDate)
from [dbo].[NashVilleHousing]


update NashVilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table NashVilleHousing
Add SaleDateConverted date;

update NashVilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

select saledateconverted
from NashVilleHousing

-- Populate Property Address data

select *
from NashVilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress, b.propertyaddress)
from NashVilleHousing a
join NashVilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.propertyaddress) 
from NashVilleHousing a
join NashVilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]


-- Breaking out Address into Indivisual Columns (Address, City, State)

select propertyaddress
from NashVilleHousing


select propertyaddress,
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress)) as City
from NashVilleHousing

alter table NashVilleHousing
Add PropertySplitCity nvarchar(200);
Go

update NashVilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress))
Go
alter table NashVilleHousing
Add PropertySplitAddress nvarchar(200);
Go
update NashVilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)
go

select * from NashVilleHousing


select OwnerAddress
from NashVilleHousing

select 
PARSENAME(replace(owneraddress,',','.'),3)
,PARSENAME(replace(owneraddress,',','.'),2)
,PARSENAME(replace(owneraddress,',','.'),1)
from NashVilleHousing


alter table NashVilleHousing
Add OwnerSplitAddress nvarchar(200);
Go

update NashVilleHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3)
Go

alter table NashVilleHousing
Add OwnerSplitCity nvarchar(200);
Go

update NashVilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2)
Go

alter table NashVilleHousing
Add OwnerSplitState nvarchar(200);
Go

update NashVilleHousing
set OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),1)
Go


-- Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(soldasvacant), count(SoldAsVacant)
from NashVilleHousing
group by SoldAsVacant 


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
from NashVilleHousing

update NashVilleHousing
set soldasvacant = 
case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end


--- Remove duplicates


with rownumCTE as (
Select *,
	row_number() over(
	partition by parcelID,
				propertyaddress,
				saledate,
				saleprice,
				legalreference
				order by
					uniqueID
					) row_num
from NashVilleHousing
--order by parcelid
)

select *
from rownumCTE
where row_num > 1
order by propertyaddress


--delete
--from rownumCTE
--where row_num > 1
--order by propertyaddress




----- Delete unsused columns

select *
from NashVilleHousing

alter table NashVilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table NashVilleHousing
drop column saledate

