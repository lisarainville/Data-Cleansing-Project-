---cleaning data in SQL Queries

select * 
from dbo.[Nashville Housing ]
----------------------------

--standarize data format from date-time format, convert 



select SalesDateConverted,convert (Date,SaleDate)
from [Nashville Housing ]

update [Nashville Housing ]
set SaleDate = convert (date, SaleDate)

alter table [Nashville Housing ]
add SalesDateConverted Date;

update [Nashville Housing ]
set SalesDateConverted = convert (date, SaleDate)

----------populate property address data


select PropertyAddress 
from [Nashville Housing ]
where PropertyAddress is null

select *
from [Nashville Housing ]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.propertyAddress, b.PropertyAddress)
from [Nashville Housing ] a
Join [Nashville Housing ] b 
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL (a.propertyAddress, b.PropertyAddress)
from [Nashville Housing ] a
Join [Nashville Housing ] b 
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----breaking out address into individual columns (address, city, state).... use substring, and character index (char index) *** use -1 to eliminate comma in querry result
--- use +1 to get to the comma in the results
select PropertyAddress
from [Nashville Housing ]

select 
SUBSTRING (propertyaddress, 1,CHARINDEX (',',propertyaddress)-1 )as address ,
SUBSTRING (propertyaddress, CHARINDEX (',',propertyaddress)+ 1 , len (propertyaddress))as address
from [Nashville Housing ]

Alter Table [Nashville Housing ]
add PropertySplitAddress Nvarchar (255);

UPdate [Nashville Housing ]
set PropertySplitAddress  = SUBSTRING (propertyaddress, 1,CHARINDEX (',',propertyaddress)-1 )           

Alter table [Nashville Housing ]
add PropertySplitCity Nvarchar (255);

Update [Nashville Housing ] 
set PropertySplitCity = SUBSTRING (propertyaddress, CHARINDEX (',',propertyaddress)+ 1 , len (propertyaddress))

select *
from [Nashville Housing ] 

--- break up Owner Address column into (address, city, state), etc. , instead of substring, use parsename (looks for periods instead of commas,
--therefore replace commas with periods ....good for delimited data) -- have to input 3,2,1 b/c results are backwards

select OwnerAddress
from [Nashville Housing ] 

select
PARSENAME (replace(OwnerAddress,',','.'), 3),
PARSENAME (replace(OwnerAddress,',','.'), 2),
PARSENAME (replace(OwnerAddress,',','.'), 1)
from [Nashville Housing ] 

---------------add columns and values 
Alter Table [Nashville Housing ]
add OwnerSplitAddress Nvarchar (255);

UPdate [Nashville Housing ]
set OwnerSplitAddress  = PARSENAME (replace(OwnerAddress,',','.'), 3)        


Alter table [Nashville Housing ]
add OwnerSplitCity Nvarchar (255);


UPdate [Nashville Housing ]
set OwnerSplitCity  = PARSENAME (replace(OwnerAddress,',','.'), 2)


Alter table [Nashville Housing ]
add OwnerSplitState Nvarchar (255);


Update [Nashville Housing ] 
set OwnerSplitState = PARSENAME (replace(OwnerAddress,',','.'), 1)

select *
from [Nashville Housing ] 

---------------------------------Change Y and N to Yes and No in "sold as vacant' field 

select distinct (SoldAsVacant), count (SoldAsVacant)
from [Nashville Housing ] 
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from [Nashville Housing ] 


update [Nashville Housing ] 
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

------------------------Remove duplicates, write a CTE, window functions to find duplicate values, want to partion data on things that should be unique to each row
with Row_NumCTE as (
select *,
ROW_NUMBER ( )over (
partition by ParcelID, PropertyAddress,SalePrice, SaleDate,LegalReference
Order by  UniqueID)
row_num
from [Nashville Housing ])
--Order by ParcelID
select *
from Row_NumCTE
where row_num > 1
order by PropertyAddress

---- now we see 104 rows of duplicates , so delete 

with Row_NumCTE as (
select *,
ROW_NUMBER ( )over (
partition by ParcelID, PropertyAddress,SalePrice, SaleDate,LegalReference
Order by  UniqueID)
row_num
from [Nashville Housing ])
--Order by ParcelID
Delete 
from Row_NumCTE
where row_num > 1

----delete some unused columns
alter table [Nashville Housing ]
drop column owneraddress, taxDistrict,propertyAddress

alter table  [Nashville Housing ]
drop column saledate
