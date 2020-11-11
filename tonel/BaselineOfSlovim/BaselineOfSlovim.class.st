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
			spec repository: 'github://ronsaldo/sasm'].
		spec baseline: #'WBT' with: [
			spec repository: 'github://ronsaldo/wbt' ].
		spec 
			package: #'Slovim-MessagePack';
			package: #'Slovim-Core' with: [
				spec requires: #(#'Slovim-MessagePack' #WBT)];
			package: #'Slovim-HighLevelCodeGenerator' with: [
				spec requires: #(#'Slovim-Core' ). ];
			package: 'Slovim-SAsmCodeGenerator' with: [
				spec requires: #(#'Slovim-Core' 'SAsm' ). ];
			package: 'LLVM-IR' with: [
				spec requires: #(#'SAsm'). ];
			package: 'Slovim-LLVMCodeGenerator' with: [
				spec requires: #(#'Slovim-Core' #'LLVM-IR'). ];
			package: #'Slovim-SpirV' with: [
				spec requires: #(#'Slovim-Core' ). ];
			package: #'Slovim-Tests' with: [
				spec requires: #(#'Slovim-Core' #'Slovim-SpirV' ). ].
			
		spec
			group: #Core with: #(#'Slovim-Core');
			group: #ShaderCompilation with: #(
				#'Slovim-SpirV'
			);
			group: #LLVM with: #(
				#'LLVM-IR'
				#'Slovim-LLVMCodeGenerator'
			);
			group: #NoLLVM with: #(
				#'Slovim-SAsmCodeGenerator'
				#ShaderCompilation
			).
	].

]
