

USE portfolio_project;

CREATE TABLE IF NOT EXISTS property_data (
    UniqueID INT,
    ParcelID VARCHAR(255),
    LandUse VARCHAR(255),
    PropertyAddress VARCHAR(255),
    SaleDate DATE,
    SalePrice DECIMAL(10, 2),
    LegalReference VARCHAR(255),
    SoldAsVacant VARCHAR(255),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage DECIMAL(10, 2),
    TaxDistrict VARCHAR(255),
    LandValue DECIMAL(10, 2),
    BuildingValue DECIMAL(10, 2),
    TotalValue DECIMAL(10, 2),
    YearBuilt YEAR,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

-- GET Everything From Dataset
select * from nashvillehousing;


-- Standardize the date format


-- 2 Populate the property Address
select * from nashvillehousing where propertyaddress is null;
SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;

-- updating blank to null
update nashvillehousing
set propertyAddress = null where propertyAddress = '';

-- trying to set the code for update statement 
select a.ParcelID, a.propertyAddress,b.ParcelID, b.propertyAddress, ifnull(a.propertyAddress, b.propertyAddress)
from  nashvillehousing a
join  nashvillehousing b
on a.parcelID = b.parcelID and a.uniqueID <> b.UniqueID
where  a.propertyAddress is null;

update portfolio_project.nashvillehousing as a 
join  portfolio_project.nashvillehousing as  b
on a.parcelID = b.parcelID and a.uniqueID <> b.UniqueID
set a.propertyaddress = ifnull(a.propertyAddress, b.propertyAddress)
where a.propertyaddress is null;

-- checking the data
select a.ParcelID, a.propertyAddress,b.ParcelID, b.propertyAddress
from  nashvillehousing a
join  nashvillehousing b
on a.parcelID = b.parcelID and a.uniqueID <> b.UniqueID;

-- 3 Splitting property Adrdress ito 2 columns (address, city)

-- first i did create 2 columns (easy thing done)
alter table nashvillehousing
add PropertyAddressSplit char(255);
alter table nashvillehousing
add PropertyAddresscitySplit char(255);

select * from nashvillehousing;

-- main thing is to split property address using sub_str

select substring_index(propertyAddress,',',1) 
from nashvillehousing;
select substring_index(propertyAddress,',',-1) 
from nashvillehousing;
 update nashvillehousing
set propertyaddresssplit = substring_index(propertyAddress,',',1);

update nashvillehousing
set propertyaddresscitysplit =substring_index(propertyAddress,',',-1);


-- Now splitting ownerAddress using substring_index

select * from nashvillehousing;

select substring_index(owneraddress,',',1)
,substring_index(owneraddress,',',-1)
, substring_index(substring_index(owneraddress,',',-2),',',1)
from nashvillehousing;

alter table nashvillehousing
add OwnerAddresssplit char(255);
alter table nashvillehousing
add OwnerAddresscitysplit char(255);
alter table nashvillehousing
add OwnerAddressstatesplit char(255);

update nashvillehousing
set OwnerAddresssplit = substring_index(owneraddress,',',1); 
update nashvillehousing
set OwnerAddresscitysplit = substring_index(substring_index(owneraddress,',',-2),',',1) ;
update nashvillehousing
set OwnerAddressstatesplit = substring_index(owneraddress,',',-1);


-- changing Y and N to Yes and No in soldvacantland column
select distinct(soldasvacant), count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by 2;

select soldasvacant,
case
	when soldasvacant = 'Y' then 'Yes'
    when soldasvacant = 'N' then 'No'
    else soldasvacant
    end
from nashvillehousing;


update nashvillehousing
set soldasvacant = case
	when soldasvacant = 'Y' then 'Yes'
    when soldasvacant = 'N' then 'No'
    else soldasvacant
    end;
    
    
    -- Removing Duplicates
select * from nashvillehousing;
    
delete from nashvillehousing
where uniqueId in (
select uniqueid
 from (select p1.uniqueID 
from nashvillehousing p1
where exists (select 1 from nashvillehousing p2
where   p2.parcelId = p1.parcelId and 
		p2.propertyAddress =p1.propertyAddress and
        p2.saleprice= p1.saleprice and
        p2.Legalreference = p1.Legalreference and 
        p2.uniqueID < p1.uniqueID) 
        ) as temp
  );
                    
                    
-- Delete Unused columns

 alter table nashvillehousing
 drop column propertyAddress,
  drop column HalfBath,
   drop column ownerAddress,
    drop column taxdistrict;
                    
