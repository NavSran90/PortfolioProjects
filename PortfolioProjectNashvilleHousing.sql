/****** Cleaning data in SQL queries*******/
Select * from NashvilleHousing

--Standardize Sale Date Format

Select SaleDateConverted,CONVERT(Date,SaleDate)
from NashvilleHousing

Alter table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted=CONVERT(Date,SaleDate)

--Populate the Property Address Data (Note fro observation, the same Parcel ID's have the same Property Address.

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,IsNULL(a.PropertyAddress,b.propertyAddress)
from NashvilleHousing a
Join NashvilleHousing b on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is NULL

Update a
set PropertyAddress=IsNULL(a.PropertyAddress,b.propertyAddress)
from NashvilleHousing a
Join NashvilleHousing b on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is NULL

--Breaking Address into Individual Columns (Address,City,State)

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from dbo.NashvilleHousing

--Added two columns for the Split Address and the City

Alter Table NashvilleHousing 
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing 
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select PropertySplitAddress,PropertySplitCity from NashvilleHousing


--Splitting the Owner Address

Select * from PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress,
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing 
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing 
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing 
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)

--Change Y and N in the SoldAsVacant field to Yes and No respectively

Select Distinct SoldAsVacant from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing set SoldAsVacant='NO' where SoldAsVacant='N'

Update NashVilleHousing set SoldAsVacant='Yes' where SoldAsVacant='Y'

Select SoldAsVacant,COUNT(SoldAsVacant) from NashvilleHousing
Group By SoldAsVacant

--Remove Duplicates
Go
With RowNumCTE as
(
Select *,
ROW_NUMBER() Over(Partition By ParcelID,PropertyAddress,
SalePrice,SaleDate,LegalReference Order by UniqueID) as row_num
from NashvilleHousing)
----order By ParcelID
Select * from RowNumCTE where row_num>1    order by PropertyAddress
--Delete from RowNumCTE where row_num>1

Select * from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress

Alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate


--Replaced the NULL values in the split columns

Select a.ParcelID,a.OwnerSplitAddress,a.OwnerSplitCity
,b.ParcelID,b.PropertySplitAddress,b.PropertySplitCity
,ISNULL(a.OwnerSplitAddress,b.PropertySplitAddress),ISNULL(a.OwnerSplitCity,b.PropertySplitCity)
From NashvilleHousing a
join NashvilleHousing b on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]

Update a
set OwnerSplitAddress = ISNULL(a.OwnerSplitAddress,b.PropertySplitAddress)
From NashvilleHousing a
join NashvilleHousing b on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]

Update a
set OwnerSplitCity=ISNULL(a.OwnerSplitCity,b.PropertySplitCity)
From NashvilleHousing a
join NashvilleHousing b on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]

