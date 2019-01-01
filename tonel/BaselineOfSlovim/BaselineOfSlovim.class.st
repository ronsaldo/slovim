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
		spec configuration: 'OSSubprocess' with: [
			spec
				versionString: #stable;
				repository: 'github://marianopeck/OSSubprocess/repository' ];
			yourself.
		spec baseline: 'SAsm' with: [
				spec
					repository: 'github://ronsaldo/sasm/tonel'].
		spec baseline: 'Lowcode' with: [
				spec
					repository: 'github://ronsaldo/lowcode/tonel';
					loads: #(#'Core') ].
		spec 
			package: #'Slovim-Core';
			package: #'Slovim-HighLevelCodeGenerator' with: [
				spec requires: #(#'Slovim-Core' ). ];
			package: 'Slovim-OpalCompiler' with: [
				spec requires: #(#'Slovim-Core' ). ];
			package: 'Slovim-SAsmCodeGenerator' with: [
				spec requires: #(#'Slovim-Core' 'SAsm' ). ];
			package: 'Slovim-StackCodeGenerator' with: [
				spec requires: #(#'Slovim-Core' ). ];
			package: 'LLVM-IR' with: [
				spec requires: #(#'SAsm' #'OSSubprocess'). ];
			package: 'Slovim-LLVMCodeGenerator' with: [
				spec requires: #(#'Slovim-Core' #'LLVM-IR'). ];
			package: 'Slovim-Runtime' with: [
				spec requires: #(). ];
			package: #'Slovim-SpirV' with: [
				spec requires: #(#'Slovim-Core' ). ];
			package: #'Slovim-Tests' with: [
				spec requires: #(#'Slovim-Core' #'Slovim-SpirV' ). ]. ].

]
