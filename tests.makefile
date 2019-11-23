### Run test
.PHONY: test
test: ${BUILD_DIR}${TARGET}
	${BUILD_DIR}${TARGET}
	@rm -f gmon.out
