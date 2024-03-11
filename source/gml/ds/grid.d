module gml.ds.grid;

import core.memory;
import std.variant;

struct DSGrid{
	private Variant[][] data;
	
	void setDimensions(size_t width, size_t height){
		const startWidth  = data.length;
		const startHeight = data.length ? data[0].length : 0;
		
		data.length = width;
		if(width > startWidth){
			if(height > startHeight){
				foreach(ref subData; data[0..startWidth]){
					subData.length = height;
					subData[startHeight..$] = Variant(0);
				}
			}else{
				foreach(ref subData; data[0..startWidth]){
					subData.length = height;
				}
			}
			foreach(ref subData; data[startWidth..$]){
				subData.length = height;
				subData[] = Variant(0);
			}
		}else{
			if(height > startHeight){
				foreach(ref subData; data){
					subData.length = height;
					subData[startHeight..$] = Variant(0);
				}
			}else{
				foreach(ref subData; data){
					subData.length = height;
				}
			}
		}
	}
	
	Variant opIndex(size_t x, size_t y){
		const width  = data.length;
		const height = width ? data[0].length : 0;
		if(x >= width || y >= height) return Variant(null);
		return data[x][y];
	}
	
	Variant opIndexAssign(V)(V val, size_t x, size_t y){
		const width  = data.length;
		const height = width ? data[0].length : 0;
		if(x >= width || y >= height) return Variant(null);
		return data[x][y] = Variant(val);
	}
}

DSGrid dsGridCreate(size_t w, size_t h){
	DSGrid ret;
	ret.setDimensions(w, h);
	return ret;
}
alias ds_grid_create = dsGridCreate;

void dsGridDestroy(ref DSGrid index) nothrow @nogc pure{
	foreach(subData; index.data){
		GC.free(subData.ptr);
	}
	GC.free(index.data.ptr);
	index.data = null;
}
alias ds_grid_destroy = dsGridDestroy;

size_t dsGridWidth(const DSGrid index) nothrow @nogc pure @safe =>
	index.data.length;
alias ds_grid_width = dsGridWidth;

size_t dsGridHeight(const DSGrid index) nothrow @nogc pure @safe =>
	index.data.length ? index.data[0].length : 0;
alias ds_grid_height = dsGridHeight;

void dsGridResize(ref DSGrid index, size_t w, size_t h){
	index.setDimensions(w, h);
}
alias ds_grid_resize = dsGridResize;

void dsGridClear(V)(ref DSGrid index, V val){
	auto varVal = Variant(val);
	foreach(ref column; index.data){
		column[] = varVal;
	}
}
alias ds_grid_clear = dsGridClear;

//TODO: see if this function silently fails when setting OOB instead of throwing an error in GML?
void dsGridSet(V)(ref DSGrid index, size_t x, size_t y, V value){
	index.data[x][y] = Variant(value);
}
alias ds_grid_set = dsGridSet;

//TODO: ds_grid_set_disk

//TODO: see if this function silently fails when setting/getting OOB instead of throwing an error in GML?
void dsGridSetGridRegion(ref DSGrid index, const DSGrid source, size_t x1, size_t y1, size_t x2, size_t y2, size_t xPos, size_t yPos){
	//const srcWidth  = source.data.length;
	//const srcHeight = srcWidth ? source.data[0].length : 0;
	x2 += 1; //`+ 1` because `x2`/`y2` are inclusive
	y2 += 1;
	const copyWidth  = x2 - x1;
	const copyHeight = y2 - y1;
	if(index == source){
		auto inter = new Variant[](copyHeight); //intermediate buffer; to avoid funny errors with writing to the buffer being read from.
		
		foreach(i; 0..copyWidth){
			inter[] = source.data[x1+i][y1..y2];
			index.data[xPos+i][yPos..yPos+copyHeight] = inter[];
		}
	}else{
		//const dstWidth  = index.data.length;
		//const dstHeight = dstWidth ? index.data[0].length : 0;
		
		foreach(i; 0..copyWidth){
			index.data[xPos+i][yPos..yPos+copyHeight] = source.data[x1+i][y1..y2];
		}
	}
}
alias ds_grid_set_grid_region = dsGridSetGridRegion;

void dsGridSetRegion(V)(ref DSGrid index, size_t x1, size_t y1, size_t x2, size_t y2, V val){
	auto varVal = Variant(val);
	foreach(ref column; index.data[x1..x2+1]){
		column[y1..y2+1] = varVal;
	}
}
alias ds_grid_set_region = dsGridSetRegion;

//ds_grid_shuffle

//ds_grid_sort

Variant dsGridGet(const DSGrid index, size_t x, size_t y) =>
	index.data[x][y];
alias ds_grid_get = dsGridGet;

unittest{
	auto grid = dsGridCreate(5, 5);
	foreach(x; 0..5){
		foreach(y; 0..5){
			assert(dsGridGet(grid, x, y) is Variant(0));
		}
	}
}
