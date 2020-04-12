Class {
	#name : #BaselineOfSlovim,
	#superclass : #BaselineOf,
	#category : #BaselineOfSlovim
}

{ #category : #baselines }
BaselineOfSlovim >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec blessing: #'baseline'.
		spec baseline: 'SAsm' with: [
				spec repository: 'github://ronsaldo/sasm/tonel'].
		spec baseline: 'Lowcode' with: [
				spec
					repository: 'github://ronsaldo/lowcode/tonel';
					loads: #(#'Core') ].
		spec 
			package: #'Slovim-MessagePack';
			package: #'Slovim-Core' with: [
				spec requires: #(#'Slovim-MessagePack')];
			package: #'Slovim-HighLevelCodeGenerator' with: [
				spec requires: #(#'Slovim-Core' ). ];
			package: 'Slovim-OpalCompiler' with: [
				spec requires: #(#'Slovim-Core' ). ];
			package: 'Slovim-SAsmCodeGenerator' with: [
				spec requires: #(#'Slovim-Core' 'SAsm' ). ];
			package: 'Slovim-StackCodeGenerator' with: [
				spec requires: #(#'Slovim-Core' ). ];
			package: 'LLVM-IR' with: [
				spec requires: #(#'SAsm'). ];
			package: 'Slovim-LLVMCodeGenerator' with: [
				spec requires: #(#'Slovim-Core' #'LLVM-IR'). ];
			package: 'Slovim-Runtime' with: [
				spec requires: #(). ];
			package: #'Slovim-SpirV' with: [
				spec requires: #(#'Slovim-Core' ). ];
			package: #'Slovim-Tests' with: [
				spec requires: #(#'Slovim-Core' #'Slovim-SpirV' ). ].
			
		spec
			group: #Core with: #(#'Slovim-Core');
			group: #ShaderCompilation with: #(
				#'Slovim-SpirV'
			);
			group: #Runtime with: #(
				#'Slovim-Runtime'
			);
			group: #InImageCompilation with: #(
				#'Slovim-StackCodeGenerator'
				#'Slovim-Runtime'
			);
			group: #LLVM with: #(
				#'LLVM-IR'
				#'Slovim-LLVMCodeGenerator'
			);
			group: #NoLLVM with: #(
				#'Slovim-SAsmCodeGenerator'
				#InImageCompilation
				#ShaderCompilation
			).
	].

]
