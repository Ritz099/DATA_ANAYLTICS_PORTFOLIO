create database r9test1;
use  r9test1;
select * from dbo.Nashville_Housing;

------------------cleaning data in SQL queries---------------- ------

select * from Nashville_Housing;

--------------------standardrise sale date------------------------------------

select SaleDate,SalesDateConverted, convert (date ,SaleDate)
From Nashville_Housing;;

alter table Nashville_Housing
add  SalesDateConverted date ;

Update Nashville_Housing
set SalesDateConverted = convert (date ,SaleDate);



----populate property address data--
 
select *
From  r9test1.dbo.Nashville_Housing
where PropertyAddress is null
order bY ParcelID;



select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
From  r9test1.dbo.Nashville_Housing a
JOIN r9test1.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

Update a
Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
From  r9test1.dbo.Nashville_Housing a
JOIN r9test1.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;




----Breaking out address into Induvisul columns (Address,City,State)--

select PropertyAddress
From r9test1.dbo.Nashville_Housing;

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)  As Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))  As City

 From r9test1.dbo.Nashville_Housing;


alter table Nashville_Housing
add  PropertysplitAddress nvarchar(256) ;

Update Nashville_Housing
set PropertysplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) ;


alter table Nashville_Housing
add  PropertysplitCity nvarchar(256) ;

Update Nashville_Housing
set PropertysplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) ;


select *
From r9test1.dbo.Nashville_Housing;




select OwnerAddress
From r9test1.dbo.Nashville_Housing;


select 
PARSENAME(Replace(OwnerAddress,',','.'),3) as Address ,
PARSENAME(Replace(OwnerAddress,',','.'),2) As city ,
PARSENAME(Replace(OwnerAddress,',','.'),1) as state
From r9test1.dbo.Nashville_Housing;



alter table Nashville_Housing
add  OwnersplitAddress nvarchar(256) ;

Update Nashville_Housing
set OwnersplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)  ;


alter table Nashville_Housing
add  OwnersplitCity nvarchar(256) ;

Update Nashville_Housing
set OwnersplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2) ;


alter table Nashville_Housing
add  OwnersplitState nvarchar(256) ;

Update Nashville_Housing
set OwnersplitState = PARSENAME(Replace(OwnerAddress,',','.'),1) ;


select *
From r9test1.dbo.Nashville_Housing;


----------change Y and N to yes and no in 'solid as vacant' feild ------
select distinct (SoldAsVacant), count(SoldAsVacant)
From Nashville_Housing
Group by SoldAsVacant
Order by 2;



select SoldAsVacant
,case	when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'NO'
		else SoldAsVacant
		end
From r9test1.dbo.Nashville_Housing;

Update Nashville_Housing
set SoldAsVacant = case	when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'NO'
						else SoldAsVacant
						end
From r9test1.dbo.Nashville_Housing;






-------------Remove Duplicate ----------------------
with Rownumcte as(
select *,
	row_number() over (
	Partition by	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by UniqueID) Row_num   				 
From Nashville_Housing
--Order by ParcelID
)
select *
from Rownumcte 
where Row_num > 1
order by PropertyAddress ;




---------- Delete unused columns -----------------------
select *
From r9test1.dbo.Nashville_Housing;


alter table Nashville_Housing
Drop column OwnerAddress,TaxDistrict,PropertyAddress