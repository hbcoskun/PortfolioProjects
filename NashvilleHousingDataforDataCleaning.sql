#https://www.youtube.com/watch?v=8rO7ztF4NtU&t=2815s
use Portfolio;
drop table if exists Portfolio.NashvilleHousing;

create table Portfolio.NashvilleHousing(
UniqueID varchar(50) DEFAULT NULL,
ParcelID varchar(50) DEFAULT NULL,	
LandUse varchar(50) DEFAULT NULL,
PropertyAddress varchar(50) DEFAULT NULL,	
SaleDate date DEFAULT NULL,	
SalePrice int DEFAULT NULL,	
LegalReference varchar(50) DEFAULT NULL,	
SoldAsVacant varchar(50) DEFAULT NULL,	
OwnerName varchar(50) DEFAULT NULL,	
OwnerAddress varchar(50) DEFAULT NULL,	
Acreage decimal(10,5) DEFAULT NULL,
TaxDistrict varchar(50) DEFAULT NULL,	
LandValue int DEFAULT NULL,
BuildingValue int DEFAULT NULL,	
TotalValue int DEFAULT NULL,	
YearBuilt year,	
Bedrooms int DEFAULT NULL,	
FullBath int DEFAULT NULL,	
HalfBath int DEFAULT NULL);

/** SHOW GLOBAL VARIABLES LIKE 'local_infile'; 
SET GLOBAL local_infile = TRUE;

SET SESSION sql_mode = ''; **/

LOAD DATA LOCAL INFILE '/Users/bet/Documents/BET/Other/other/Courses/Programming:Software/DataAnalytics/Portfolio/AlexTheAnalyst/Part3/NashvilleHousingDataforDataCleaning.csv'
INTO TABLE Portfolio.NashvilleHousing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

select count(*) from Portfolio.NashvilleHousing;


/** Cleaning everything in SQL Queries **/
select * from Portfolio.NashvilleHousing;

/** Change SaleDate Format **/
select SaleDate, convert(SaleDate, date) from Portfolio.NashvilleHousing;

update Portfolio.NashvilleHousing
set SaleDate = convert(SaleDate, date);

#OR

alter table Portfolio.NashvilleHousing
add SaleDateConverted date;

update Portfolio.NashvilleHousing
set SaleDateConverted = convert(SaleDate, date);

alter table Portfolio.NashvilleHousing
drop SaleDateConverted;

/** Populate Property Address Data **/
select * from Portfolio.NashvilleHousing
#where PropertyAddress = "";
order by ParcelID; #ParcelID can be mached to PropertyAddress and then the null PropertyAddress can be populated

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, nullif(b.PropertyAddress,a.PropertyAddress) as FillInAddress
from Portfolio.NashvilleHousing a
join Portfolio.NashvilleHousing b 
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress = "";

update Portfolio.NashvilleHousing a #when you;re doing join, NashvilleHouseing doesn't work, you need to use it by its alias. 
inner join Portfolio.NashvilleHousing b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
set a.PropertyAddress = nullif(b.PropertyAddress,a.PropertyAddress)
where a.PropertyAddress = "";

/** Breaking our Address into Individual Columns (Address, City, State) **/
select PropertyAddress from Portfolio.NashvilleHousing;
#where PropertyAddress = "";
#order by ParcelID; 

select
substring_index(PropertyAddress,',',1) as Address1, #in place of substring and charindex. 
substring_index(PropertyAddress,',',-1) as Address2
from Portfolio.NashvilleHousing;
#starting at the first value, it shows characters until a comma.

#select 
#substring(PropertyAddress,1,locate(',','PropertyAddress')) as Address #charindex: to find any phrases within the quotation marks in the table
																	   #1:what we are looking for, 2:where we are looking
#from Portfolio.NashvilleHousing;

alter table Portfolio.NashvilleHousing
add PropertySplitAddress varchar(255);

update Portfolio.NashvilleHousing
set PropertySplitAddress = substring_index(PropertyAddress,',',1);

alter table Portfolio.NashvilleHousing
add PropertySplitCity varchar(255);

update Portfolio.NashvilleHousing
set PropertySplitCity = substring_index(PropertyAddress,',',-1);

select * from Portfolio.NashvilleHousing;

select OwnerAddress from Portfolio.NashvilleHousing;

select
parsename(replace(OwnerAddress,',','.'),1),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),3)
from Portfolio.NashvilleHousing; #For some reason, this does not work, ugh

select
substring_index(OwnerAddress,',',-1) as Owner1,
substring_index(OwnerAddress,',',1) as Owner2,
substring_index(OwnerAddress,',',-2) as Owner3
from Portfolio.NashvilleHousing;

/** Change Y and N to Yes and No in "Solid as Vacant" field **/
select Distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio.NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
	end
from Portfolio.NashvilleHousing;

update Portfolio.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
    end;

/** Remove Duplicates **/
#not done very often

with RowNumCTE as( #CTE: Common table expression. building a "subquery". putting it in a temporary place where we can grab the data. 
select *,
	row_number() over(
    partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
                LegalReference
                order by
					UniqueID
                    ) as row_num
from Portfolio.NashvilleHousing
)
select * from RowNumCTE
where row_num > 1
order by PropertyAddress;

drop table if exists RowNumCTE;

create table RowNumCTE as(
select *,
	row_number() over(
    partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
                LegalReference
                order by
					UniqueID
                    ) as row_num
from Portfolio.NashvilleHousing
);

select * from RowNumCTE;

#alter table Portfolio.NashvilleHousing
#drop row_num;

alter table Portfolio.NashvilleHousing
add row_num int;

update Portfolio.NashvilleHousing a  
join Portfolio.RowNumCTE b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
set a.row_num = b.row_num;

delete from Portfolio.NashvilleHousing
where row_num > 1;

SHOW FULL PROCESSLIST;
KILL 10;

/** Delete Unused Columns **/
select * from Portfolio.NashvilleHousing;

alter table Portfolio.NashvilleHousing
drop column OwnerAddress, 
drop column TaxDistrict, 
drop column PropertyAddress;

alter table Portfolio.NashvilleHousing
drop column SaleDate;