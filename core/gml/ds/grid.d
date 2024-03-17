module gml.ds.grid;

import gml.maths;

import core.memory;
import std.algorithm.sorting, std.math, std.random, std.variant, std.uni;

void init(){
	
}

struct DSGrid{
	Variant[][] data;
	alias data this;
	
	@property width()  const => data.length ? data[0].length : 0;
	@property height() const => data.length;
	
	void setDimensions(size_t newWidth, size_t newHeight){
		const oldWidth  = width;
		const oldHeight = height;
		
		data.length = newHeight;
		if(newHeight > oldHeight){
			if(newWidth > oldWidth){
				foreach(ref subData; data[0..oldHeight]){
					subData.length = newWidth;
					subData[oldWidth..$] = Variant(0);
				}
			}else{
				foreach(ref subData; data[0..oldHeight]){
					subData.length = newWidth;
				}
			}
			foreach(ref subData; data[oldHeight..$]){
				subData.length = newWidth;
				subData[] = Variant(0);
			}
		}else{
			if(newWidth > oldWidth){
				foreach(ref subData; data){
					subData.length = newWidth;
					subData[oldWidth..$] = Variant(0);
				}
			}else{
				foreach(ref subData; data){
					subData.length = newWidth;
				}
			}
		}
	}
	
	Variant opIndex(size_t x, size_t y){
		if(x >= width || y >= height) return Variant(null);
		return data[y][x];
	}
	
	Variant opIndexAssign(V)(V val, size_t x, size_t y){
		if(x >= width || y >= height) return Variant(null);
		return data[y][x] = Variant(val);
	}
}

DSGrid dsGridCreate(size_t w, size_t h){
	DSGrid ret;
	ret.setDimensions(w, h);
	return ret;
}
alias ds_grid_create = dsGridCreate;

void dsGridDestroy(ref DSGrid index) nothrow @nogc pure{
	foreach(row; index.data){
		GC.free(row.ptr);
	}
	GC.free(index.data.ptr);
	index.data = null;
}
alias ds_grid_destroy = dsGridDestroy;

size_t dsGridWidth(const DSGrid index) nothrow @nogc pure @safe =>
	index.width;
alias ds_grid_width = dsGridWidth;

size_t dsGridHeight(const DSGrid index) nothrow @nogc pure @safe =>
	index.height;
alias ds_grid_height = dsGridHeight;

void dsGridResize(ref DSGrid index, size_t w, size_t h){
	index.setDimensions(w, h);
}
alias ds_grid_resize = dsGridResize;

void dsGridClear(V)(ref DSGrid index, V val){
	auto varVal = Variant(val);
	foreach(ref row; index.data){
		row[] = varVal;
	}
}
alias ds_grid_clear = dsGridClear;

//TODO: see if this function silently fails when setting OOB instead of throwing an error in GML?
void dsGridSet(V)(ref DSGrid index, size_t x, size_t y, V value){
	index.data[y][x] = Variant(value);
}
alias ds_grid_set = dsGridSet;

//TODO: ds_grid_set_disk

//TODO: see if this function silently fails when setting/getting OOB instead of throwing an error in GML?
void dsGridSetGridRegion(ref DSGrid index, const DSGrid source, size_t x1, size_t y1, size_t x2, size_t y2, size_t xPos, size_t yPos){
	//const srcWidth  = source.width;
	//const srcHeight = source.height;
	x2 += 1; //`+ 1` because `x2`/`y2` are inclusive
	y2 += 1;
	const copyWidth  = x2 - x1;
	const copyHeight = y2 - y1;
	if(index == source){
		auto inter = new Variant[](copyWidth); //intermediate buffer; to avoid funny errors with writing to the buffer being read from.
		
		foreach(i; 0..copyHeight){
			inter[] = source.data[y1+i][x1..x2];
			index.data[yPos+i][xPos..xPos+copyWidth] = inter[];
		}
	}else{
		//const dstWidth  = index.width;
		//const dstHeight = index.height;
		
		foreach(i; 0..copyHeight){
			index.data[yPos+i][xPos..xPos+copyWidth] = source.data[y1+i][x1..x2];
		}
	}
}
alias ds_grid_set_grid_region = dsGridSetGridRegion;

void dsGridSetRegion(V)(ref DSGrid index, size_t x1, size_t y1, size_t x2, size_t y2, V val){
	auto varVal = Variant(val);
	foreach(ref row; index.data[y1..y2+1]){
		row[x1..x2+1] = varVal;
	}
}
alias ds_grid_set_region = dsGridSetRegion;

void dsGridShuffle(ref DSGrid index){
	const width  = index.width;
	const height = index.height;
	Variant[] arr;
	arr.reserve(width * height);
	foreach(row; index.data){
		arr ~= row;
	}
	arr.randomShuffle(gml.maths.rng);
	size_t arrInd;
	foreach(ref row; index.data){
		row[] = arr[arrInd..arrInd+width];
		arrInd += width;
	}
}
alias ds_grid_shuffle = dsGridShuffle;
unittest{
	auto grid = dsGridCreate(5, 5);
	foreach(x; 0..5){
		foreach(y; 0..5){
			dsGridSet(grid, x, y, x + y*5);
		}
	}
	assert(grid[0,1] ==  5);
	assert(grid[1,4] == 21);
	assert(grid[3,2] == 13);
	dsGridShuffle(grid);
	assert(grid[0,1] !=  5);
	assert(grid[1,4] != 21);
	assert(grid[3,2] != 13);
}

void dsGridSort(ref DSGrid index, size_t column, bool ascending){
	if(ascending){
		index.data.sort!((aRow, bRow){
			auto a = aRow[column];
			auto b = bRow[column];
			if(a.convertsTo!long && b.convertsTo!long){
				return a.coerce!long() < b.coerce!long();
			}
			if(a.convertsTo!double && b.convertsTo!double){
				return a.coerce!double().cmp(b.coerce!double()) < 0;
			}
			if(a.convertsTo!string && b.convertsTo!string){
				return a.coerce!string().sicmp(b.coerce!string()) < 0;
			}
			if(a.convertsTo!double && b.convertsTo!string){
				return true;
			}/*else if(a.convertsTo!string && b.convertsTo!double){
				return false;
			}*/
			return false; //TODO: work out how `undefined` is sorted
		})();
	}else{
		index.data.sort!((aRow, bRow){
			auto a = aRow[column];
			auto b = bRow[column];
			if(a.convertsTo!long && b.convertsTo!long){
				return a.coerce!long() > b.coerce!long();
			}
			if(a.convertsTo!double && b.convertsTo!double){
				return a.coerce!double().cmp(b.coerce!double()) > 0;
			}
			if(a.convertsTo!string && b.convertsTo!string){
				return a.coerce!string().sicmp(b.coerce!string()) > 0;
			}
			/*if(a.convertsTo!double && b.convertsTo!string){
				return false;
			}else */if(a.convertsTo!string && b.convertsTo!double){
				return true;
			}
			return false; //TODO: work out how `undefined` is sorted
		})();
	}
}
alias ds_grid_sort = dsGridSort;
unittest{
	auto grid = dsGridCreate(2, 3);
	dsGridSet(grid, 0, 0, "Mary");
	dsGridSet(grid, 1, 0, 1);
	dsGridSet(grid, 0, 1, "Kate");
	dsGridSet(grid, 1, 1, 2);
	dsGridSet(grid, 0, 2, "Ashley");
	dsGridSet(grid, 1, 2, 3);
	dsGridSort(grid, 0, true);
	assert(dsGridGet(grid, 0, 0) == Variant("Ashley"));
	assert(dsGridGet(grid, 1, 0) == Variant(3));
	assert(dsGridGet(grid, 0, 1) == Variant("Kate"));
	assert(dsGridGet(grid, 1, 1) == Variant(2));
	assert(dsGridGet(grid, 0, 2) == Variant("Mary"));
	assert(dsGridGet(grid, 1, 2) == Variant(1));
	dsGridSort(grid, 0, false);
	assert(dsGridGet(grid, 0, 0) == Variant("Mary"));
	assert(dsGridGet(grid, 1, 0) == Variant(1));
	assert(dsGridGet(grid, 0, 1) == Variant("Kate"));
	assert(dsGridGet(grid, 1, 1) == Variant(2));
	assert(dsGridGet(grid, 0, 2) == Variant("Ashley"));
	assert(dsGridGet(grid, 1, 2) == Variant(3));
}

Variant dsGridGet(const DSGrid index, size_t x, size_t y) =>
	index.data[y][x];
alias ds_grid_get = dsGridGet;
unittest{
	auto grid = dsGridCreate(5, 5);
	foreach(x; 0..5){
		foreach(y; 0..5){
			assert(dsGridGet(grid, x, y) is Variant(0));
		}
	}
}

//TODO: The docs say this returns 'Real or String'. How does this function work with strings?
Variant dsGridGetMax(DSGrid index, size_t x1, size_t y1, size_t x2, size_t y2){
	double maxVal = -double.infinity;
	foreach(row; index.data[y1..y2+1]){
		foreach(item; row[x1..x2+1]){
			if(item.convertsTo!double){
				const itemDouble = item.coerce!double();
				if(itemDouble.cmp(maxVal) > 0){
					maxVal = itemDouble;
				}
			}
		}
	}
	return Variant(maxVal);
}
alias ds_grid_get_max = dsGridGetMax;
unittest{
	auto grid = dsGridCreate(5, 5);
	foreach(x; 0..5){
		foreach(y; 0..5){
			dsGridSet(grid, x, y, x + y*5);
		}
	}
	assert(dsGridGetMax(grid, 1,1, 3,3) == 18.0);
}

//TODO: The docs say this returns 'Real or String'. How the actual fuck does this function work with strings?
Variant dsGridGetMean(DSGrid index, size_t x1, size_t y1, size_t x2, size_t y2){
	double sum = 0.0;
	uint count = 0;
	foreach(row; index.data[y1..y2+1]){
		foreach(item; row[x1..x2+1]){
			if(item.convertsTo!double){
				sum += item.coerce!double();
				count++;
			}
		}
	}
	return Variant(sum / cast(double)count);
}
alias ds_grid_get_mean = dsGridGetMean;
unittest{
	auto grid = dsGridCreate(5, 5);
	foreach(x; 0..5){
		foreach(y; 0..5){
			dsGridSet(grid, x, y, x + y*5);
		}
	}
	assert(dsGridGetMean(grid, 1,1, 3,3) == 12.0);
}

//TODO: The docs say this returns 'Real or String'. How does this function work with strings?
Variant dsGridGetMin(DSGrid index, size_t x1, size_t y1, size_t x2, size_t y2){
	double maxVal = double.infinity;
	foreach(row; index.data[y1..y2+1]){
		foreach(item; row[x1..x2+1]){
			if(item.convertsTo!double){
				const itemDouble = item.coerce!double();
				if(itemDouble.cmp(maxVal) < 0){
					maxVal = itemDouble;
				}
			}
		}
	}
	return Variant(maxVal);
}
alias ds_grid_get_min = dsGridGetMin;
unittest{
	auto grid = dsGridCreate(5, 5);
	foreach(x; 0..5){
		foreach(y; 0..5){
			dsGridSet(grid, x, y, -(x + y*5));
		}
	}
	assert(dsGridGetMin(grid, 1,1, 3,3) == -18.0);
}

//TODO: The docs say this returns 'Real or String'. How the actual fuck does this function work with strings?
Variant dsGridGetSum(DSGrid index, size_t x1, size_t y1, size_t x2, size_t y2){
	double sum = 0.0;
	foreach(row; index.data[y1..y2+1]){
		foreach(item; row[x1..x2+1]){
			sum += item.coerce!double();
		}
	}
	return Variant(sum);
}
alias ds_grid_get_sum = dsGridGetSum;
unittest{
	auto grid = dsGridCreate(5, 5);
	foreach(x; 0..5){
		foreach(y; 0..5){
			dsGridSet(grid, x, y, x + y*5);
		}
	}
	assert(dsGridGetSum(grid, 1,1, 3,3) == 108.0);
}

//TODO: ds_grid_get_disk_max

//TODO: ds_grid_get_disk_mean

//TODO: ds_grid_get_disk_min

//TODO: ds_grid_get_disk_sum

void dsGridAdd(N)(ref DSGrid index, size_t x, size_t y, N val)
if(__traits(isArithmetic, N)){
	index.data[y][x] = index.data[y][x] + val;
}
void dsGridAdd(N)(ref DSGrid index, size_t x, size_t y, string val){
	index.data[y][x] = index.data[y][x] ~ val;
}
alias ds_grid_add = dsGridAdd;

void dsGridAddRegion(V)(ref DSGrid index, size_t x1, size_t y1, size_t x2, size_t y2, V val){
	foreach(y; y1..y2+1){
		foreach(x; x1..x2+1){
			dsGridAdd(item, x, y, val);
		}
	}
}
alias ds_grid_add_region = dsGridAddRegion;

//TODO: ds_grid_add_disk

void dsGridAddGridRegion(ref DSGrid index, DSGrid source, size_t x1, size_t y1, size_t x2, size_t y2, size_t xPos, size_t yPos){
	x2 += 1; //`+ 1` because `x2`/`y2` are inclusive
	y2 += 1;
	const copyWidth  = x2 - x1;
	const copyHeight = y2 - y1;
	if(index == source){
		auto inter = new Variant[](copyWidth); //intermediate buffer; to avoid funny errors with writing to the buffer being read from.
		
		foreach(i; 0..copyHeight){
			inter[] = source.data[y1+i][x1..x2];
			foreach(j, varSrc; inter){
				auto varDst = index.data[yPos+i][xPos+j];
				if(varDst.convertsTo!string){
					varDst ~= varSrc;
				}else{
					varDst += varSrc;
				}
				index.data[yPos+i][xPos+j] = varDst;
			}
		}
	}else{
		foreach(i; 0..copyHeight){
			foreach(j; 0..copyWidth){
				auto varSrc = source.data[y1+i][x1+j];
				auto varDst = index.data[yPos+i][xPos+j];
				if(varDst.convertsTo!string){
					varDst ~= varSrc;
				}else{
					varDst += varSrc;
				}
				index.data[yPos+i][xPos+j] = varDst;
			}
		}
	}
}
alias ds_grid_add_grid_region = dsGridAddGridRegion;

void dsGridMultiply(N)(ref DSGrid index, size_t x, size_t y, N val)
if(__traits(isArithmetic, N)){
	index.data[y][x] = index.data[y][x] * val;
}
alias ds_grid_multiply = dsGridMultiply;

//TODO: ds_grid_multiply_disk

//TODO: ds_grid_multiply_region

//TODO: ds_grid_multiply_grid_region

//TODO: ds_grid_value_exists

//TODO: ds_grid_value_disk_exists

//TODO: ds_grid_value_x

//TODO: ds_grid_value_y

//TODO: ds_grid_value_disk_x

//TODO: ds_grid_value_disk_y

void dsGridCopy(ref DSGrid destination, DSGrid source){
	destination.setDimensions(source.width, source.height);
	foreach(i, ref row; destination.data){
		row[] = source.data[i][];
	}
}
alias ds_grid_copy = dsGridCopy;

//TODO: ds_grid_read

//TODO: ds_grid_write

//TODO: ds_grid_to_mp_grid
