//iz file_shaders_testing.dart

  //FRESNEL SHADER DUDDDDDDDDE
//     ShaderMaterial fresnelSphere = new ShaderMaterial(fragmentShader: Shaders.);
//     String fresnelVertex = FresnelShader["vertexShader"];
//     print(fresnelVertex);
//     String fresnelFragment = FresnelShader["fragmentShader"];
//     Map<String, Uniform> fresnelUniforms = new Map<String, Uniform>();
//         Uniform mRefractionRatio = new Uniform.float(1.02);
//         Uniform mFresnelBias = new Uniform.float(0.1);
//         Uniform mFresnelPower = new Uniform.float(2.0);
//         Uniform mFresnelScale = new Uniform.float(1.0);
//         Uniform tCube = new Uniform.texture(ImageUTILS.loadTexture('textures_shaders_testing/cloud.png'));
//         
//         fresnelUniforms["mRefractionRatio"] = mRefractionRatio;
//         fresnelUniforms["mFresnelBias"] = mFresnelBias;
//         fresnelUniforms["mFresnelPower"] = mFresnelPower;
//         fresnelUniforms["mFresnelScale"] = mFresnelScale;
//         //Tu neki ImageUTILS.loadTextureCube koji se predaje u tCube uniform TODO
//         fresnelUniforms["tCube"] = tCube;
//         
//         ShaderMaterial fresnelMaterial = new ShaderMaterial(fragmentShader: fresnelFragment, vertexShader: fresnelVertex, uniforms: fresnelUniforms);
//
//         Mesh fresnelSphere = new Mesh(new SphereGeometry(100.0), fresnelMaterial);
//         scene.add(fresnelSphere);