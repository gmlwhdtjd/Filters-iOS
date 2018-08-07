//
//  ChromaticAberrationKernel.metal
//  Custom Filters
//
//  Created by Hui Jong Lee on 2018. 8. 6..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h>

extern "C" {
    namespace coreimage {
        float4 chromaticAberrationColor(sampler src, float intensity) {
            
            float2 dis = src.coord().xy;
            dis -= 0.5;
            dis *= intensity * 0.05;
            float3 target = float3(src.sample(src.coord()).r,
                                   src.sample(src.coord() - dis).g,
                                   src.sample(src.coord() - dis*2).b);

            return float4(target, 1.0);
        }
    }
}
